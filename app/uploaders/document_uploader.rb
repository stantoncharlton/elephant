# encoding: utf-8

class DocumentUploader < CarrierWave::Uploader::Base
    include CarrierWaveDirect::Uploader

    # Include the Sprockets helpers for Rails 3.1+ asset pipeline compatibility:
    include Sprockets::Helpers::RailsHelper
    include Sprockets::Helpers::IsolatedHelper

    include CarrierWave::MimeTypes
    process :set_content_type

end