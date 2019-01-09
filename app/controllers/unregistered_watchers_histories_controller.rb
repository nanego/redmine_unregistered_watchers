class UnregisteredWatchersHistoriesController < ApplicationController

  before_action :require_admin
  layout "admin"

  helper :sort
  include SortHelper

  def index
    sort_init "created_at", "desc"
    sort_update %w(id subject created_at)

    scope = UnregisteredWatchersHistory.all

    @limit = per_page_option
    @mails_count = scope.count
    @mails_pages = Paginator.new @mails_count, @limit, params[:page]
    @offset ||= @mails_pages.offset
    @mails =  scope.order(sort_clause).limit(@limit).offset(@offset)

    render :layout => !request.xhr?
  end

  def show
    @mail = UnregisteredWatchersHistory.find(params[:id].to_i)
  end

end
