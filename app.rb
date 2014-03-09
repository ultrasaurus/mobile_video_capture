require 'sinatra'
require 'aws/s3'

get "/" do
  "<h1>Hello World</h1>
<form action='/upload' method='post' accept-charset='utf-8' enctype='multipart/form-data'>
  <label for='content_file'>Image</label>
  <input type='file' name='content[file]' id='content_file' />
  <button type='submit'>Save</button>
</form>
"
end

post '/upload' do
  puts params.inspect
  upload(params[:content]['file'][:filename], params[:content]['file'][:tempfile])
  redirect '/'
end



def upload(filename, file)
  bucket = 'mobile-video-capture-bucket'
  AWS::S3::Base.establish_connection!(
    :access_key_id     => ENV['S3_ACCESS_KEY_ID'],
    :secret_access_key => ENV['S3_SECRET_ACCESS_KEY']
  )
  AWS::S3::S3Object.store(
    filename,
    open(file.path),
    bucket
  )
  return filename
end
