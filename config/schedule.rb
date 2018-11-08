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
  rake 'jobs:workoff'
end

# 記事の公開/非公開処理を行います。
every '0,15,30,45 * * * *' do
  rake 'sys:tasks:exec'
end

# トップページのみを静的ファイルとして書き出します。
every '02-47/15 * * * *' do
  rake 'cms:nodes:publish_top'
end

# 固定ページを静的ファイルとして書き出します。
every '4-49/15 * * * *' do
  rake 'cms:nodes:publish'
end

# 記事コンテンツの分野ディレクトリを静的ファイルとして書き出します。
every '12 * * * *' do
  rake 'cms:nodes:publish_category'
end

# 記事コンテンツの属性ディレクトリを静的ファイルとして書き出します。
every '22 * * * *' do
  rake 'cms:nodes:publish_attribute'
end

# 記事コンテンツの地域ディレクトリを静的ファイルとして書き出します。
every '32 * * * *' do
  rake 'cms:nodes:publish_area'
end

# 記事コンテンツの組織ディレクトリを静的ファイルとして書き出します。
every '42 * * * *' do
  rake 'cms:nodes:publish_unit'
end

# 音声ファイルを静的ファイルとして書き出します。
every '10-40/30 * * * *' do
  rake 'cms:talks:publish'
end

# フィード取り込みます。
every '20-50/30 * * * *' do
  rake 'cms:feeds:read'
end

# メルマガ読者登録を取り込みます。
every '05-55/10 * * * *' do
  rake 'newsletter:requests:read'
end

# # アンケート投稿を取り込みます。
every '24-54/30 * * * *' do
  rake 'enquete:answers:pull'
end

# # 掲示板投稿を取り込みます。
every '24-54/30 * * * *' do
  rake 'bbs:threads:pull'
end

# # 記事再構築(ページ)
# every '00 * * * *' do
  # rake 'article:docs:rebuild'
# end

# # FAQ再構築(ページ)
# every '00 * * * *' do
  # rake 'faq:docs:rebuild'
# end

# # DBセッション削除
# every '00 * * * *' do
  # rake 'db:session:sweep'
# end
