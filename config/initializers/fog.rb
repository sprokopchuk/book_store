
CarrierWave.configure do |config|
  #config.fog_provider = 'fog/aws'                        # required
  config.fog_credentials = {
    provider:              'AWS',                        # required
    aws_access_key_id:     'AKIAJIPWRT4PCINEKW6Q',                        # required
    aws_secret_access_key: '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',                        # required
    region:                'eu-central-1',                  # optional, defaults to 'us-east-1'
    host:                  'http://s3.amazonaws.com',
    endpoint:              'https://s3.eu-central-1.amazonaws.com' # optional, defaults to nil
  }
  config.fog_public     = true
  config.fog_directory  = 'imagespsv2109'                          # required
end
