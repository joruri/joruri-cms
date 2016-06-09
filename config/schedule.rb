# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

rails_env = ENV['RAILS_ENV'] || :production
set :environment, rails_env

set :output, nil

env :PATH, ENV['PATH']

# http://rubygems.org/gems/delayed_job_active_record
every 3.minutes do
  rake 'jobs:workoff MIN_PRIORITY=0 MAX_PRIORITY=10'
end
every 3.minutes do
  rake 'jobs:workoff MIN_PRIORITY=11'
end

# 記事の公開/非公開処理を行います。
every '10,25,40,55 * * * *' do
  rake 'sys:tasks:exec'
end

# トップページのみを静的ファイルとして書き出します。
every '*/3 * * * *' do
  rake 'cms:nodes:publish_top'
end

# トップページや中間ページを静的ファイルとして書き出します。
every '*/30 * * * *' do
  rake 'cms:nodes:publish'
end

# 音声ファイルを静的ファイルとして書き出します。
every '*/15 * * * *' do
  rake 'cms:talks:publish'
end

# フィード取り込みます。
every '*/30 * * * *' do
  rake 'cms:feeds:read'
end

# メルマガ読者登録の取り込みます。
every '*/10 * * * *' do
  rake 'newsletter:requests:read'
end

# アンケート取り込み
every '#00 * * * *' do
  rake 'enquete:answers:pull'
end

# 記事再構築(ページ)
every '#00 * * * *' do
  rake 'article:docs:rebuild'
end

# FAQ再構築(ページ)
every '#00 * * * *' do
  rake 'faq:docs:rebuild'
end

# DBセッション削除
every '#00 * * * *' do
  rake 'db:session:sweep'
end
