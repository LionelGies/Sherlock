class VideosController < ApplicationController

  before_filter :authenticate_user!
  before_filter :authorize_pi!

  #
  # Note: we may want to remove it, if this controller will also be
  #       used to upload videos unlinked with any blocks/cases
  #
  before_filter :resolve_case, :only => [ :new, :edit, :show, :update, :create ]
  before_filter :verify_case_author!, :only => [ :new, :edit, :update, :create ]
  def new

    block = Block.new
    block.case = @case
    @video  = Video.generate(block)
    @insert_before_id = params[:insert_before_id].to_i
    @cookie = cookies['_sherlock_session']
  end

  def create

    params[:upload] ||= {}

    params[:upload].delete('thumbnail') if params[:video][:thumbnail_method] == 'auto'
    params[:video].delete(:thumbnail_method)

    params[:upload]['video'] =
    TempVideo.get_upload_for_user(self.current_company) if uploaded_via_tmp?

    video     = params[:upload]['video']
    thumbnail = params[:upload]['thumbnail']

    params[:video][:uploaded_file] = video if video
    params[:video][:uploaded_thumbnail] = thumbnail if thumbnail

    @video = Video.new(params[:video])
    @video.block = Block.new(
    :case             => @case,
    :insert_before_id => params[:insert_before_id].to_i
    )

    respond_to do |format|
      if (@video.save)
        TempVideo.remove_for_user(current_company) if uploaded_via_tmp?
        format.html { redirect_to(@case, :notice => 'Video block has been added') }
      else
        format.html { render :action => 'new' }
      end
    end

  end

  #
  # Uploadify makes this strange call to /cases/<case_id>/videos/false - not
  # sure why
  #
  def show
    video_id = params[:id]
    @video = video_id.to_s == 'false' ? nil : @case.videos.find_by_unique_code(video_id)

    respond_to do |format|
      format.html { render :text => 'json call expected' }
      format.js { render :json => @video }
    end
  end

  def edit
    @insert_before_id = 0

    @video = @case.videos.find_by_id(params[:id])

    @cookie = cookies['_sherlock_session']
    redirect_to cases_path unless @video
  end

  def update

    @video = @case.videos.find_by_id(params[:id])
    redirect_to cases_path unless @video

    if uploaded_via_tmp?
      params[:upload] ||= {}
      params[:upload]['video'] = TempVideo.get_upload_for_user(self.current_company)
    end

    has_upload = params[:upload]
    method_auto = params[:video][:thumbnail_method].to_s == 'auto'

    params[:upload].delete :thumbnail if has_upload && method_auto
    if params[:keep_thumbnail].to_i == 1
      params[:video].delete :thumbnail_pos
      params[:upload].delete :thumbnail if has_upload
    end
    params[:video].delete :thumbnail_pos unless method_auto
    params[:video].delete :thumbnail_method

    if has_upload
      video     = params[:upload]['video']
      thumbnail = params[:upload]['thumbnail']
      params[:video][:uploaded_file] = video if video
      params[:video][:uploaded_thumbnail] = thumbnail if thumbnail
    end

    respond_to do |format|
      if @video.update_attributes(params[:video])
        TempVideo.remove_for_user(current_company) if uploaded_via_tmp?
        format.html { redirect_to(@case, :notice => 'The video has been successfully updated') }
      else
        format.html do
          flash[:alert] = 'The video could not be updated'
          render :action => 'edit'
        end
      end
    end

  end

  private

  def uploaded_via_tmp?
    params[:via_tmp].to_i == 1
  end

  def resolve_case
    resolve_case_using_param(:case_id)
  end

  def verify_case_author!
    is_author = (@case.author == current_company)
    redirect_to @case unless is_author
  end

end
