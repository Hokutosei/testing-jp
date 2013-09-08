class Admin::CsvOutputController < Admin::BaseController
  layout "output"
  before_filter :login_required

  # 主页
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw 20130705
  def index
    @outputs = CsvOutput.find(:all, :conditions => ["input_server_name = ?", "dev"])
    return unless request.post?
    school_id = params[:school_id]
    server_name = params[:server_id]
    project_name = params[:project_id]
    sort = params[:sort]
    upflag = params[:upflag].to_s == "1"
    return flash[:notice] = "加盟校IDを入力してください。" if school_id.blank?
    if upflag
      import_server_name = params[:import_server_id]
      #admin_mark = params[:admin_mark_guid]
      #return flash[:notice] = "標識IDが不正です。" if admin_mark != session[:admin_mark_guid]
      CsvInput.input(school_id, server_name, project_name, import_server_name)
      flash[:notice] = "データを更新しました。"
    else
      #admin_mark = session[:admin_mark_guid]
      return_error = CsvOutput.output(school_id, server_name, project_name)
      return flash[:notice] = "加盟校IDが不正です。" if return_error == "error001"
      output = CsvOutput.find(:first, :conditions => ["project_name = ? and server_name = ? and school_id = ? and output_flag = ? and input_server_name = ? and sort = ?", project_name, server_name, school_id, true, "dev", sort])
      CsvOutput.create(:project_name => project_name, :server_name => server_name, :school_id => school_id, :output_flag => true, :input_server_name => "dev", :sort => sort) if output.blank?
      @outputs = CsvOutput.find(:all, :conditions => ["project_name = ? and server_name = ?", project_name, server_name])
      redirect_to :action => 'list', :school_id => params[:school_id], :server_name => params[:server_id], :project_name => params[:project_id], :sort => sort
    end
  end

  # 主页
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw 20130705
  def benfan
    @outputs = CsvOutput.find(:all, :conditions => ["input_server_name = ?", "benfan"])
    return unless request.post?
    school_id = params[:school_id]
    server_name = params[:server_id]
    project_name = params[:project_id]
    sort = params[:sort]
    upflag = params[:upflag].to_s == "1"
    return flash[:notice] = "加盟校IDを入力してください。" if school_id.blank?
    if upflag
      import_server_name = params[:import_server_id]
      #admin_mark = params[:admin_mark_guid]
      #return flash[:notice] = "標識IDが不正です。" if admin_mark != session[:admin_mark_guid]
      CsvInput.input(school_id, server_name, project_name, import_server_name)
      flash[:notice] = "データを更新しました。"
    else
      #admin_mark = session[:admin_mark_guid]
      return_error = CsvOutput.output(school_id, server_name, project_name)
      return flash[:notice] = "加盟校IDが不正です。" if return_error == "error001"
      outpuut = CsvOutput.find(:first, :conditions => ["project_name = ? and server_name = ? and school_id = ? and output_flag = ? and input_server_name = ? and sort = ?", project_name, server_name, school_id, true, "benfan", sort])
      CsvOutput.create(:project_name => project_name, :server_name => server_name, :school_id => school_id, :output_flag => true, :input_server_name => "benfan", :sort => sort) if output.blank?
      @outputs = CsvOutput.find(:all, :conditions => ["project_name = ? and server_name = ?"])
      redirect_to :action => 'list', :school_id =>params[:school_id], :server_name => params[:server_id], :project_name => params[:project_id], :sort => sort
    end
  end

  # 主页
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw 20130705
  def local
    @outputs = CsvOutput.find(:all, :conditions => ["input_server_name = ?", "local"])
    return unless request.post?
    school_id = params[:school_id]
    server_name = params[:server_id]
    project_name = params[:project_id]
    sort = params[:sort]
    upflag = params[:upflag].to_s == "1"
    return flash[:notice] = "加盟校IDを入力してください。" if school_id.blank?
    if upflag
      import_server_name = params[:import_server_id]
      #admin_mark = params[:admin_mark_guid]
      #return flash[:notice] = "標識IDが不正です。" if admin_mark != session[:admin_mark_guid]
      CsvInput.input(school_id, server_name, project_name, import_server_name)
      flash[:notice] = "データを更新しました。"
    else
      #admin_mark = session[:admin_mark_guid]
      return_error = CsvOutput.output(school_id, server_name, project_name)
      return flash[:notice] = "加盟校IDが不正です。" if return_error == "error001"
      output = CsvOutput.find(:first, :conditions => ["project_name = ? and server_name = ? and school_id = ? and output_flag = ? and input_server_name = ? and sort = ?", project_name, server_name, school_id, true, "local", sort])
      CsvOutput.create(:project_name => project_name, :server_name => server_name, :school_id => school_id, :output_flag => true, :input_server_name => "local", :sort => sort) if output.blank?
      @outputs = CsvOutput.find(:all, :conditions => ["project_name = ? and server_name = ?", project_name, server_name])
      redirect_to :action => 'list', :school_id =>params[:school_id], :server_name => params[:server_id], :project_name => params[:project_id], :sort => sort
    end
  end

  #导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zq20130808
  def import
    output = CsvOutput.find_by_id(params[:id])
    return redirect_to :action => "index" if output.blank?
    school_id = output.school_id
    server_name = output.server_name
    project_name = output.project_name
    sort = params[:sort]
    import_server_name = params[:import_server_id]
    puts '==============='
    puts 'will import now'	
    CsvInput.input(school_id, server_name, project_name, import_server_name, sort)
    output.input_flag = true
    output.save(false)
    case server_name
      when "local"
        rec_action = "local"
      when "staging"
        rec_action = "test_env"
      when "benfan"
        rec_action = "benfan"
      else
        rec_action = "index"
    end
    render :update do |page|
      flash[:notice] = "データを更新しました。"
      page.redirect_to :action => rec_action
    end
  end

  # 导出
  #显示所有的导出文件
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw 20130801
  def list
     csv_file_path = RAILS_ROOT + "/public/#{params[:project_name]}/#{params[:server_name]}/#{params[:school_id]}"
     @files = []
     Dir.foreach(csv_file_path){|file|  @files << file}
     sort = params[:sort]
     sort_array = CsvOutput.sort_file_array(sort)
     @files = @files.select{|file|file.include?(".csv") && sort_array.include?(file)}.sort
     #@files = (@files - [".",".."]).sort
  end

  # 导出
  #下载导出的文件
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw 20130801
  def download
     output = RAILS_ROOT + "/public/#{params[:project_name]}/#{params[:server_name]}/#{params[:school_id]}/#{params[:file]}"
     send_file(output, :type => 'text/csv' )
  end

  def test_env
    @outputs = CsvOutput.find(:all, :conditions => ["input_server_name = ?", "staging"])
    return unless request.post?
    school_id = params[:school_id]
    server_name = params[:server_id]
    project_name = params[:project_id]
    sort = params[:sort]
    upflag = params[:upflag].to_s == "1"
    return flash[:notice] = "加盟校IDを入力してください。" if school_id.blank?
    if upflag
      import_server_name = params[:import_server_id]
      #admin_mark = params[:admin_mark_guid]
      #return flash[:notice] = "標識IDが不正です。" if admin_mark != session[:admin_mark_guid]
      CsvInput.input(school_id, server_name, project_name, import_server_name)
      flash[:notice] = "データを更新しました。"
    else
      #admin_mark = session[:admin_mark_guid]
      return_error = CsvOutput.output(school_id, server_name, project_name)
      return flash[:notice] = "加盟校IDが不正です。" if return_error == "error001"
      output = CsvOutput.find(:first, :conditions => ["project_name = ? and server_name = ? and school_id = ? and output_flag = ? and input_server_name = ? and sort = ?", project_name, server_name, school_id, true, "staging", sort])
      CsvOutput.create(:project_name => project_name, :server_name => server_name, :school_id => school_id, :output_flag => true, :input_server_name => "staging", :sort => sort) if output.blank?
      @outputs = CsvOutput.find(:all, :conditions => ["project_name = ? and server_name = ?", project_name, server_name])
      redirect_to :action => 'list', :school_id => params[:school_id], :server_name => params[:server_id], :project_name => params[:project_id], :sort => sort
    end
  end

  # 导出
  #下载导出的文件
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zq 20130814
  def view_input_log
    id = params[:id]
    output = CsvOutput.find_by_id(id)
    return if output.blank?
    time = output.input_time.present? ? output.input_time : Time.now
    file_path = "#{RAILS_ROOT}/log/input_#{'local'}_#{output.school_id}_#{time.strftime('%Y%m%d')}.log"
    return render :text => "wrong file" unless File.exist?(file_path)
    @logs = []
    file = File.open(file_path)
    file.each do |line|
      @logs << line
    end
  end

end
