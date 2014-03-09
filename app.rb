require 'sinatra'
require 'aws/s3'

BUCKET_NAME = 'mobile-video-capture-bucket'

get "/" do
  connect
  page = "<h1>Hello World</h1>
<form action='/upload' method='post' accept-charset='utf-8' enctype='multipart/form-data'>
  <label for='content_file'>Image</label>
  <input type='file' name='content[file]' id='content_file' />
  <button type='submit'>Save</button>
</form>"

  page += "<ul>"
  bucket = AWS::S3::Bucket.find(BUCKET_NAME)
  bucket.each do |object|
      page += "<li><a href='http://mobile-video-capture-bucket.s3-website-us-east-1.amazonaws.com/#{object.key}'>#{object.key}</a>\t#{object.about['content-length']}\t#{object.about['last-modified']}</li>"
  end
  page += "<ul>"

  page
end

post '/upload' do
  puts params.inspect
  upload(params[:content]['file'][:filename], params[:content]['file'][:tempfile])
  redirect '/'
end


def connect
  AWS::S3::Base.establish_connection!(
    :access_key_id     => ENV['S3_ACCESS_KEY_ID'],
    :secret_access_key => ENV['S3_SECRET_ACCESS_KEY']
  )
end

def upload(filename, file)
  puts "----------------- upload -------------------"
  connect
  AWS::S3::S3Object.store(
    filename,
    open(file.path),
    BUCKET_NAME
  )
  policy = AWS::S3::S3Object.acl(filename, BUCKET_NAME)
  policy.grants = [ AWS::S3::ACL::Grant.grant(:public_read) ]
  AWS::S3::S3Object.acl(filename, BUCKET_NAME, policy)

  return filename
end
