require 'aws-sdk-costexplorer'
require 'net/http'
require 'uri'
require 'json'
require 'dotenv/load'

TOKEN = ENV['LINE_TOKEN'].freeze
  URL = 'https://notify-api.line.me/api/notify'.freeze

# Lambdaのエントリーポイント
def notify(event:, context:)
  fetch_cost
    .then { |response| pretty_response(response) }
    .then { |message| notify_line(message) }

  # 一応HTTPレスポンスとして返す
  { statusCode: 200, body: 'ok' }
end

# 請求情報の取得
def fetch_cost(time = Time.now)
  # 認証は既にすんでるのでcredentialsいらない(後述)
  client = Aws::CostExplorer::Client.new(region: 'us-east-1')

  client.get_cost_and_usage(
    time_period: {
      start: Date.new(time.year, time.month, 1).strftime('%F'),
      end: Date.new(time.year, time.month, -1).strftime('%F'),
    },
    granularity: 'MONTHLY',
    metrics: ['AmortizedCost'],
    group_by: [ { type: "DIMENSION",key: 'SERVICE' }]
  )
end

# APIの返り値の整形
def pretty_response(res)
  total_amount = 0
  # 適当
  total_unit = nil
  service_billings = []

  res.
    results_by_time[0].
    groups.
    sort { |a, b| b.metrics['AmortizedCost'].amount.to_f <=> a.metrics['AmortizedCost'].amount.to_f }.
    each { |item|
      # 小数点2以下は切り上げ
      amount = item.metrics['AmortizedCost'].amount.to_f.ceil(2)
      next if amount.zero?
      unit = item.metrics['AmortizedCost'].unit

      service_billings << "#{item.keys[0]}: #{amount} #{unit}"
      # 総額計算
      total_amount = total_amount + amount
      total_unit ||= item.metrics['AmortizedCost'].unit
    }

  <<~EOS
    #{res.results_by_time[0].time_period.start}〜#{res.results_by_time[0].time_period.end}の請求額はおよそ #{total_amount.ceil(2)} #{total_unit} です。
    ----- 内訳 -----
    #{service_billings.join("\n")}
  EOS
end

# Slackに投稿
def notify_line(message)
  # incoming Webhook設定したURLを環境変数にセット
  uri = URI.parse(URL)
  request = Net::HTTP::Post.new(uri)
  request['Authorization'] = "Bearer #{TOKEN}"
  request.set_form_data(message: message)
  Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |https|
    https.request(request)
  end
end
