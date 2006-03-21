class AdminController < ApplicationController
  layout 'default'
  
  def index
    @site_mappings = SiteMapping.find(:all, :order => 'root_id, lft')
    if params[:mapping_id] then
      @site_mapping = SiteMapping.find(params[:mapping_id])
      @chunk_version = @site_mapping.chunk.find_version() if @site_mapping.chunk
      @chunk = @chunk_version.chunk if @chunk_version
      send_data @chunk_version.content, :filename => @site_mapping.path_segment, :type => @chunk.mime_type, :disposition => 'inline' if @chunk && @chunk.is_binary?
    else
    end
  end
  
  def new_document
    @site_mapping = SiteMapping.new
    @site_mapping.parent_id = params[:mapping_id]
    
    @chunk = Chunk.new
    @chunk_version = ChunkVersion.new
  end
  
  def store_document
    mime_type = MimeType.find_by_file_name(params[:site_mapping][:path_segment])
  
    chunk = Chunk.new(params[:chunk])
    chunk.live_version = 1
    chunk.mime_type = mime_type.id
    chunk.save
    
    chunk_version = chunk.chunk_versions.create(params[:chunk_version])
    chunk_version.version = 1
    chunk_version.save
    
    site_mapping = SiteMapping.new(params[:site_mapping])
    site_mapping.chunk_id = chunk.id
    site_mapping.lft = 0
    site_mapping.rgt = 0
    site_mapping.depth = 0
    site_mapping.parent_id = 0 unless site_mapping.parent_id
    site_mapping.save
    
    redirect_to :action => 'index'
  end
  
  def edit_document
    @site_mapping = SiteMapping.find(params[:site_mapping_id])
    @chunk_version = ChunkVersion.find(params[:chunk_version_id])
    @chunk = @chunk_version.chunk
  end
  
  def update_document
    @site_mapping = SiteMapping.find(params[:site_mapping_id])
    @chunk_version = ChunkVersion.find(params[:chunk_version_id])
    @chunk = @chunk_version.chunk
    
    live_version = (@chunk_version.version + 1)
    version = @chunk.chunk_versions.create (params[:chunk_version])
    version.base_version = @chunk_version.version
    version.version = live_version
    version.save
    
    @chunk.update_attributes(params[:chunk])
    @chunk.live_version = live_version
    @chunk.save
    
    @site_mapping.update_attributes(params[:site_mapping])
    @site_mapping.save
    
    redirect_to :action => 'index'
  end
  
  def new_folder
    @site_mapping = SiteMapping.new
    @site_mapping.parent_id = params[:mapping_id]
  end
  
  def store_folder
    site_mapping = SiteMapping.new(params[:site_mapping])
    site_mapping.lft = 0
    site_mapping.rgt = 0
    site_mapping.depth = 0
    site_mapping.parent_id = 0 unless site_mapping.parent_id
    site_mapping.save
    
    redirect_to :action => 'index'
  end
  
  def edit_folder
    @site_mapping = SiteMapping.find(params[:mapping_id])
  end
  
  def update_folder
    @site_mapping = SiteMapping.find(params[:site_mapping_id])
    @site_mapping.update_attributes(params[:site_mapping])
    @site_mapping.save
    
    redirect_to :action => 'index'
  end
  
  # See 
  #  * [http://wiki.rubyonrails.org/rails/pages/HowtoUploadFiles HowtoUploadFiles]
  #  * [http://wiki.rubyonrails.org/rails/pages/Upload+Progress+Bar Upload Progress Bar]
  #  * [http://manuals.rubyonrails.com/read/chapter/56 Sending and receiving files]
  #  * http://api.rubyonrails.com/classes/ActionController/Streaming.html send_data API]
  #  * [http://scottraymond.net/articles/2005/07/05/caching-images-in-rails Caching]
  def upload
    @site_mapping = SiteMapping.new
    @site_mapping.parent_id = params[:mapping_id]
    
    @chunk = Chunk.new
    @chunk_version = ChunkVersion.new
  end
  
  def store_uploaded
    file_name = params['chunk_version']['tmp_file'].original_filename.gsub(/[^a-zA-Z0-9.]/, '_') # This makes sure filenames are sane
    mime_type = MimeType.find_by_file_name(file_name)
puts "\tMIME TYPE: #{mime_type}"
puts "\tMIME TYPE.ID: #{mime_type.id}"
    @params['chunk_version']['content'] = @params['chunk_version']['tmp_file'].read
    @params['chunk_version'].delete('tmp_file')
    
    chunk = Chunk.new(params[:chunk])
    chunk.live_version = 1
    chunk.mime_type_id = mime_type.id
    chunk.save
    
    chunk_version = chunk.chunk_versions.create(params[:chunk_version])
    chunk_version.version = 1
    chunk_version.save
    
    site_mapping = SiteMapping.new(params[:site_mapping])
    site_mapping.path_segment = file_name
    site_mapping.chunk_id = chunk.id
    site_mapping.lft = 0
    site_mapping.rgt = 0
    site_mapping.depth = 0
    site_mapping.parent_id = 0 unless site_mapping.parent_id
    site_mapping.save
    
    redirect_to :action => 'index'
  end
end
