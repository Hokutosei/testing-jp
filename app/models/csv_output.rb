class CsvOutput < ActiveRecord::Base
  #acts_as_paranoid
  #  establish_connection :test_development
  LOCAL_SERVER = [["", "local"]]
  SERVER_SELECT = [["テストサーバ", "dev"], ["ステージングサーバ", "staging"], ['本番サーバー', 'production']]
  BENFAN_SERVER = [["本番サーバ", "benfan"]]
  PROJECT_SELECT = [["SC", "schoolcity"], ["LG", "livegate"], ["SZ", "shozemi"]]
  SC_DB_SELECT = [["local", "192.168.75.221", "root", "123456", "sc_benfan"],
    ["dev", "49.212.88.128", "school", "L7hi3eRw", "sc_dev"],
    ["staging", "49.212.94.82", "school", "6EO4TYdp", "SC_production"],
    ['production', '49.212.79.216', 'school','FtGsjY3O', 'SC_production' ],
#    ['production', 'localhost', 'root','jinpol', 'school_city_development' ],
    ["benfan", "49.212.79.216", "school", "FtGsjY3O", "SC_production"]
  ]
  LG_DB_SELECT = [["local", "192.168.75.221", "root", "123456", "live_gate"],
    ["dev", "192.168.75.221", "root", "123456", "live_gate"],
    ["staging", "192.168.75.221", "root", "123456", "live_gate"],
    ['production', '49.212.79.216', 'school','FtGsjY3O', 'SC_production' ],
    ["benfan", "192.168.75.221", "root", "123456", "live_gate"]
  ]
  SZ_DB_SELECT = [["local", "192.168.75.221", "root", "123456", "sh_development"],
    ["dev", "192.168.75.221", "root", "123456", "sh_development"],
    ["staging", "192.168.75.221", "root", "123456", "sh_development"],
    ['production', '49.212.79.216', 'school','FtGsjY3O', 'SC_production' ],
    ["benfan", "192.168.75.221", "root", "123456", "sh_development"]
  ]

  #49.212.79.216
  #database: SC_production
  #username: school
  #password: FtGsjY3O


  SORT1 = ["admins.csv", "courses.csv", "users.csv", "subjects.csv", "contents.csv",
    "subject_contents.csv", "course_categories.csv", "libraries.csv", "free_pages.csv", "course_teachers.csv",
    "exams.csv", "exam_titles.csv", "exam_questions.csv", "exam_question_choices.csv", "purchase.csv",
    "enquetes.csv", "enquete_users.csv", "enquete_courses.csv", "enquete_questions.csv", "nquete_questions_choices.csv",
    "homeworks.csv", "contact_courses.csv", "purchase_logs.csv", "lms_scorms.csv", "purchase_confirm_logs.csv",
    "school_users.csv", "comments.csv", "user_sns.csv", "mess_groups.csv", "user_groups.csv",
    "user_scorms.csv", "taggings.csv", "tags.csv"]
  SORT2 = ["infos.csv", "course_infos.csv", "exam_result_totals.csv", "exam_results.csv", "exam_result_details.csv",
    "course_email_temps.csv", "email_templates.csv", "inquiries.csv", "message_folders.csv", "messages.csv",
    "attachments.csv", "subject_study_logs.csv", "enquete_results.csv", "enquete_result_details.csv", "file_shares.csv",
    "file_share_replies.csv", "scorm_study_logs.csv", "user_login_logs.csv", "receivers.csv"]
  SORT3 = ["lives.csv", "setting_cols.csv", "record_servers.csv", "force_converts.csv", "course_lives.csv",
    "lives_urls.csv", "iframe_urls.csv", "live_users.csv", "view_members.csv", "archives.csv",
    "live_user_hopes", "tv_action_logs", "tv_chat_logs", "tv_file_sends", "tv_layouts",
    "tv_status", "tv_streams.csv", "tv_enquetes.csv", "tv_questions.csv", "tv_enquete_results.csv",
    "schedules.csv", "schedule_courses.csv", "schedule_user_hopes.csv", "favorites.csv", "ckeditor_assets.csv"
  ]
  SORT_SELECT = [["1", "1"], ["2", "2"], ["3", "3"], ["1&2", "4"], ["1&2&3", "5"]]

  def show_project_name
    project_name = self.project_name
    case project_name
    when "livegate"
      return "LG"
    when "shozemi"
      return "SZ"
    else
      return "SC"
    end
  end

  def show_status
    self.input_flag? ? "完了" : "未完了"
  end

  def show_server
    server_name = self.server_name
    case server_name
    when "dev"
      return "テスト1"
    when "staging"
      return "ステージング"
    when "benfan"
      return "本番"

    else
      return "ローカル"
    end
  end

  # 显示优先度
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zq20130820
  def show_sort
    sort = self.sort.to_i
    #如果sort是nil，是以前导出的数据，sort不显示
    return "" if sort == 0
    return SORT_SELECT[sort - 1][0]
  end

  # 选择要数据库信息
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zq20130820
  def self.sort_file_array(sort)
    case sort
    when "1"
      return SORT1
    when "2"
      return SORT2
    when "3"
      return SORT3
    when "4"
      return (SORT1 + SORT2)
    when "5"
      return (SORT1 + SORT2 + SORT3)
    else
      return (SORT1 + SORT2 + SORT3)
    end
  end
  # 选择要数据库信息
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zq20130726
  def self.db_select(server_name, project_name)
    if project_name == "schoolcity"
      case server_name
      when "dev"
        return SC_DB_SELECT[1][1], SC_DB_SELECT[1][2], SC_DB_SELECT[1][3], SC_DB_SELECT[1][4]
      when "staging"
        return SC_DB_SELECT[2][1], SC_DB_SELECT[2][2], SC_DB_SELECT[2][3], SC_DB_SELECT[2][4]
      when "production"
        return SC_DB_SELECT[3][1], SC_DB_SELECT[3][2], SC_DB_SELECT[3][3], SC_DB_SELECT[3][4]
      when "benfan"
        return SC_DB_SELECT[4][1], SC_DB_SELECT[4][2], SC_DB_SELECT[4][3], SC_DB_SELECT[4][4]
      else
        return SC_DB_SELECT[0][1], SC_DB_SELECT[0][2], SC_DB_SELECT[0][3], SC_DB_SELECT[0][4]
      end
    elsif project_name == "livegate"
      case server_name
      when "dev"
        return LG_DB_SELECT[1][1], LG_DB_SELECT[1][2], LG_DB_SELECT[1][3], LG_DB_SELECT[1][4]
      when "staging"
        return LG_DB_SELECT[2][1], LG_DB_SELECT[2][2], LG_DB_SELECT[2][3], LG_DB_SELECT[2][4]
      when "benfan"
        return LG_DB_SELECT[3][1], LG_DB_SELECT[3][2], LG_DB_SELECT[3][3], LG_DB_SELECT[3][4]
      else
        return LG_DB_SELECT[0][1], LG_DB_SELECT[0][2], LG_DB_SELECT[0][3], LG_DB_SELECT[0][4]
      end
    elsif project_name == "shozemi"
      case server_name
      when "dev"
        return SZ_DB_SELECT[1][1], SZ_DB_SELECT[1][2], SZ_DB_SELECT[1][3], SZ_DB_SELECT[1][4]
      when "staging"
        return SZ_DB_SELECT[2][1], SZ_DB_SELECT[2][2], SZ_DB_SELECT[2][3], SZ_DB_SELECT[2][4]
      when "benfan"
        return SZ_DB_SELECT[3][1], SZ_DB_SELECT[3][2], SZ_DB_SELECT[3][3], SZ_DB_SELECT[3][4]
      else
        return SZ_DB_SELECT[0][1], SZ_DB_SELECT[0][2], SZ_DB_SELECT[0][3], SZ_DB_SELECT[0][4]
      end
    else
      return SC_DB_SELECT[0][1], SC_DB_SELECT[0][2], SC_DB_SELECT[0][3], SC_DB_SELECT[0][4]
    end
  end

  # 将加盟校下的 csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw 20130705
  def self.output(id, server_name="local", project_name="schoolcity")
    #define log
    output_log = Logger.new("#{RAILS_ROOT}/log/output_#{Time.now.strftime("%Y%m%d")}.txt")
    output_log.formatter = Logger::Formatter.new
    output_log.datetime_format = "%Y-%m-%d %H:%M:%S"
    mysql = Mysql.init()
    #选择数据库
    db_server,user_name,user_pass,db_name = db_select(server_name, project_name)
    #连接数据库
    output_log.info "================db server info ================="
    output_log.info "-----output_ip:#{db_server},---output_user_name:#{user_name},----output_user_pass:#{user_pass},--output_database:#{db_name} ================="
    mysql.connect(db_server,user_name,user_pass,db_name);
    #设置编码方式
    mysql.query("SET NAMES UTF8 ")
    #创建文件夹
    csv_file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}"
    FileUtils.mkdir_p(csv_file_path, :mode => 0755) unless File.exist?(csv_file_path)

    #write log
    output_log.info "================output start ================="
    output_log.info "===========school_id: #{id},server_name:#{server_name}============"

    #admins csv 导出
    output_log.info "====admins output start====sort:1========"
    admin_ids = out_put_admins(id, server_name, project_name, mysql)
    return "error001" if admin_ids.blank?

    #courses csv 导出
    output_log.info "====courses output start====sort:1========"
    course_ids = out_put_courses(id, server_name, project_name, mysql)

    #users csv 导出
    output_log.info "=====uses output start====sort:1========"
    user_ids = out_put_users(id, server_name, project_name, mysql)
    
    #subjects csv导出
    output_log.info "====subjects output start=====sort:1======="
    subject_ids = out_put_subjects(course_ids, id, server_name, project_name, mysql) if course_ids.present?

    #contents csv导出
    output_log.info "====contents output start====sort:1========"
    content_ids = out_put_contents( id, server_name, project_name, mysql)

    #subject_contents csv导出
    output_log.info "====subject_contents output start====sort:1========"
    subject_content_ids = out_put_subject_contents(subject_ids, id, server_name, project_name, mysql)  if subject_ids.present?

    #course_categories csv 导出
    output_log.info "====course_categories output start====sort:1========"
    out_put_course_categories(id, server_name, project_name, mysql, course_ids) if course_ids.present?

    #libraries csv导出
    output_log.info "====libraries output start====sort:1========"
    library_ids = out_put_libraries(course_ids, id, server_name, project_name, mysql) if course_ids.present?

    #freepage 导出
    output_log.info "====free_pages output start====sort:1========"
    out_put_free_pages(id,admin_ids, server_name, project_name, mysql)  if admin_ids.present?

    #course_teachers csv导出
    output_log.info "====course_teachers output start====sort:1========"
    out_put_course_teachers(course_ids, admin_ids, id, server_name, project_name, mysql) if course_ids.present? && admin_ids.present?

    #exams csv导出
    output_log.info "====exams output start====sort:1========"
    exam_ids = out_put_exams(course_ids, id, server_name, project_name, mysql) if course_ids.present?

    #exam_titles csv导出
    output_log.info "====exam_titles output start====sort:1========"
    exam_title_ids = out_put_exam_titles(exam_ids, id, server_name, project_name, mysql) if exam_ids.present?

    #exam_questions csv导出
    output_log.info "====exam_questions output start====sort:1========"
    exam_question_ids = out_put_exam_questions(exam_ids, exam_title_ids, id, server_name, project_name, mysql) if exam_ids.present? && exam_title_ids.present?

    #exam_question_choices csv导出
    output_log.info "====exam_question_choices output start====sort:1========"
    out_put_exam_question_choices(exam_question_ids, id, server_name, project_name, mysql) if exam_question_ids.present?
    
    #purchases csv 导出
    output_log.info "====purchases output start====sort:1========"
    purchase_ids = out_put_purchases(course_ids, id, server_name, project_name, mysql) if course_ids.present?

    #enquetes csv导出
    output_log.info "====enquetes output start====sort:1========"
    enquete_ids = out_put_enquetes( admin_ids, id, server_name, project_name, mysql) if admin_ids.present?

    #enquete_users csv导出
    output_log.info "====enquete_users output start====sort:1========"
    out_put_enquete_users(enquete_ids, user_ids, id, server_name, project_name, mysql) if user_ids.present? && enquete_ids.present?

    #enquete_courses csv导出
    output_log.info "====enquete_courses output start====sort:1========"
    out_put_enquete_courses(enquete_ids, course_ids, id, server_name, project_name, mysql) if course_ids.present? && enquete_ids.present?

    #enquete_questions csv导出
    output_log.info "====enquete_questions output start====sort:1========"
    enquete_question_ids = out_put_enquete_questions(enquete_ids, id, server_name, project_name, mysql) if enquete_ids.present?

    #enquete_questions_choices csv导出
    output_log.info "====enquete_questions_choices output start====sort:1========"
    out_put_enquete_questions_choices(enquete_question_ids, id, server_name, project_name, mysql) if enquete_question_ids.present?

    #homeworks csv导出
    output_log.info "====homeworks output start====sort:1========"
    homework_ids = out_put_homeworks(course_ids, id, server_name, project_name, mysql) if course_ids.present?

    #contact_courses csv导出
    output_log.info "====contact_courses output start====sort:1========"
    out_put_contact_courses(course_ids, id, server_name, project_name, mysql) if course_ids.present?

    #purchase_logs csv导出
    output_log.info "====purchase_logs output start====sort:1========"
    out_put_purchase_logs(purchase_ids, id, server_name, project_name, mysql) if purchase_ids.present?

    #lms_scorms csv导出
    output_log.info "====lms_scorms output start====sort:1========"
    lms_scorm_ids = out_put_lms_scorms(content_ids ,id, server_name, project_name, mysql) if content_ids.present?

    #purchase_confirm_logs csv导出
    output_log.info "====purchase_confirm_logs output start====sort:1========"
    out_put_purchase_confirm_logs(id, server_name, project_name, mysql)

    #school_users csv 导出
    output_log.info "====school_uses output start====sort:1========"
    out_put_school_users(id, server_name, project_name, mysql)

    #comments csv导出
    output_log.info "====comments output start====sort:1========"
    out_put_comments(user_ids, course_ids, id, server_name, project_name, mysql) if course_ids.present? && user_ids.present?

    #user_sns csv 导出
    output_log.info "====user_sns output start====sort:1========"
    out_put_user_sns(id,user_ids, server_name, project_name, mysql) if user_ids.present?

    #mess_groups csv导出
    output_log.info "====mess_groups output start====sort:1========"
    mess_group_ids = out_put_mess_groups( id, server_name, project_name, mysql)

    #user_groups csv导出
    output_log.info "====user_groups output start====sort:1========"
    out_put_user_groups(mess_group_ids, id, server_name, project_name, mysql) if mess_group_ids.present?

   
    #user_scorms csv导出
    output_log.info "====user_scorms output start====sort:1========"
    out_put_user_scorms( lms_scorm_ids, id, server_name, project_name, mysql) if  lms_scorm_ids.present?

    #taggings csv导出
    output_log.info "====taggings output start====sort:1========"
    tagging_ids = out_put_taggings(user_ids,library_ids,content_ids,enquete_ids,course_ids, id, server_name, project_name, mysql) if user_ids.present?|| library_ids.present? || content_ids.present? || enquete_ids.present?

    #tags csv导出
    output_log.info "====tags output start====sort:1========"
    tag_ids = out_put_tags( id, server_name, project_name, mysql, tagging_ids) if tagging_ids.present?

    #infos csv导出
    output_log.info "====infos output start====sort:2========"
    info_ids = out_put_infos(admin_ids, id, server_name, project_name, mysql) if admin_ids.present?

    #course_infos csv导出
    output_log.info "====course_infos output start====sort:2========"
    out_put_course_infos(info_ids, course_ids, id, server_name, project_name, mysql) if info_ids.present? && course_ids.present?

    #exam_result_totals csv导出
    output_log.info "====exam_result_totals output start====sort:2========"
    exam_result_total_ids = out_put_exam_result_totals(user_ids, exam_ids, id, server_name, project_name, mysql) if exam_ids.present? && user_ids.present?

    #exam_results csv导出
    output_log.info "====exam_results output start====sort:2========"
    exam_result_ids = out_put_exam_results(user_ids, exam_ids, id, server_name, project_name, mysql) if exam_ids.present? && user_ids.present?

    #exam_result_details csv导出
    output_log.info "====exam_result_details output start====sort:2========"
    exam_result_detail_ids = out_put_exam_result_details(exam_result_ids, exam_question_ids, id, server_name, project_name, mysql) if exam_result_ids.present? && exam_question_ids.present?

    #course_email_temps csv
    output_log.info "====course_email_temps output start====sort:2========"
    out_put_course_email_temps(course_ids, id, server_name, project_name, mysql) if course_ids.present?

    #email_templates csv 导出
    output_log.info "====email_templates output start====sort:2========"
    email_template_ids = out_put_email_templates(id, server_name, project_name, mysql)
    
    #inquiries csv导出
    output_log.info "====inquiries output start====sort:2========"
    out_put_inquiries( id, server_name, project_name, mysql)

    #message_folders csv 导出
    output_log.info "====message_folders output start====sort:2========"
    message_folder_ids = out_put_message_folders(admin_ids,user_ids, id, server_name, project_name, mysql) if admin_ids.present? || user_ids.present?

    #messages csv导出
    output_log.info "====messages output start====sort:2========"
    message_ids = out_put_messages(admin_ids,user_ids,message_folder_ids,course_ids, id, server_name, project_name, mysql) if admin_ids.present? || user_ids.present? && message_folder_ids.present? && course_ids.present?

    #attachments csv导出
    output_log.info "====attachments output start====sort:2========"
    out_put_attachments(message_ids, id, server_name, project_name, mysql) if message_ids.present?

    #subject_study_logs csv导出
    output_log.info "====subject_study_logs output start====sort:2========"
    out_put_subject_study_logs(subject_content_ids, subject_ids, user_ids, id, server_name, project_name, mysql) if subject_ids.present? && subject_content_ids.present? && user_ids.present?

    #enquete_results csv导出
    output_log.info "====enquete_results output start====sort:2========"
    enquete_result_ids = out_put_enquete_results(enquete_ids, user_ids, id, server_name, project_name, mysql) if user_ids.present? && enquete_ids.present?
   
    #enquete_result_details csv导出
    output_log.info "====enquete_result_details output start====sort:2========"
    out_put_enquete_result_details(enquete_result_ids, enquete_question_ids, id, server_name, project_name, mysql) if enquete_question_ids.present? && enquete_result_ids.present?

    #file_shares csv导出
    output_log.info "====file_shares output start====sort:2========"
    file_share_ids = out_put_file_shares(admin_ids ,user_ids,course_ids, id, server_name, project_name, mysql) if user_ids.present? && course_ids.present? && admin_ids.present?

    #file_share_replies csv导出
    output_log.info "====file_share_replies output start====sort:2========"
    out_put_file_share_replies(admin_ids ,user_ids,file_share_ids, id, server_name, project_name, mysql) if user_ids.present? && file_share_ids.present? && admin_ids.present?

    #scorm_study_logs csv导出
    output_log.info "====scorm_study_logs output start====sort:2========"
    out_put_scorm_study_logs( lms_scorm_ids, id, server_name, project_name, mysql) if lms_scorm_ids.present?

    #user_login_logs csv 导出
    output_log.info "====user_login_logs output start====sort:2========"
    out_put_user_login_logs(id, user_ids, server_name, project_name, mysql) if user_ids.present?

    #receivers csv导出
    output_log.info "====receivers output start====sort:2========"
    out_put_receivers(message_ids, id, server_name, project_name, mysql) if message_ids.present?

    #lives csv 导出
    output_log.info "====lives output start====sort:3========"
    live_ids = out_put_lives(id, server_name, project_name, mysql)

    #setting_cols csv 导出
    output_log.info "====setting_cols output start====sort:3========"
    out_put_setting_cols(id, server_name, project_name, mysql)

    #record_servers csv 导出
    output_log.info "====record_servers output start====sort:3========"
    out_put_record_servers(live_ids,id, server_name, project_name, mysql) if live_ids.present?

    #force_converts csv导出
    output_log.info "====force_converts output start====sort:3========"
    out_put_force_converts(live_ids,id, server_name, project_name, mysql) if live_ids.present?

    #course_lives csv导出
     output_log.info "====course_lives output start====sort:3========"
    out_put_course_lives(course_ids,id, server_name, project_name, mysql) if course_ids.present?


    #lives_urls csv导出
    output_log.info "====lives_urls output start====sort:3========"
    out_put_lives_urls(live_ids, id, server_name, project_name, mysql) if live_ids.present?

    #iframe_urls csv导出
    output_log.info "====iframe_urls output start====sort:3========"
    out_put_iframe_urls(live_ids, id, server_name, project_name, mysql)  if live_ids.present?

    #live_users csv导出
    output_log.info "====live_users output start====sort:3========"
    out_put_live_users(user_ids,live_ids, id, server_name, project_name, mysql)  if live_ids.present? && user_ids.present?

    #view_members csv导出
    output_log.info "====view_members output start====sort:3========"
    out_put_view_members(live_ids,user_ids, id, server_name, project_name, mysql) if live_ids.present? && user_ids.present?

    #archives csv导出
    output_log.info "====archives output start====sort:3========"
    archive_ids = out_put_archives(live_ids, id, server_name, project_name, mysql) if live_ids.present?

    #live_user_hopes  csv导出
    output_log.info "====live_user_hopes output start====sort:3========"
    out_put_live_user_hopes(live_ids,user_ids, id, server_name, project_name, mysql) if live_ids.present? && user_ids.present?

    #tv_action_logs csv导出
    output_log.info "====tv_action_logs output start====sort:3========"
    out_put_tv_action_logs(live_ids,user_ids, id, server_name, project_name, mysql) if live_ids.present? && user_ids.present?

    #tv_chat_logs csv导出
    output_log.info "====tv_chat_logs output start====sort:3========"
    out_put_tv_chat_logs(live_ids,user_ids, id, server_name, project_name, mysql) if live_ids.present? && user_ids.present?

    #tv_file_sends csv导出
    output_log.info "====tv_file_sends output start====sort:3========"
    out_put_tv_file_sends(live_ids, id, server_name, project_name, mysql) if live_ids.present?

    #tv_layouts csv导出
    output_log.info "====tv_layouts output start====sort:3========"
    out_put_tv_layouts(live_ids, id, server_name, project_name, mysql) if live_ids.present?

    #tv_status csv导出
    output_log.info "====tv_status output start=====sort:3======="
    out_put_tv_status(live_ids,user_ids, id, server_name, project_name, mysql) if live_ids.present? && user_ids.present?

    #tv_streams csv导出
    output_log.info "====tv_streams output start====sort:3========"
    out_put_tv_streams(live_ids,user_ids, id, server_name, project_name, mysql) if live_ids.present? && user_ids.present?

    #tv_enquetes csv导出
    output_log.info "====tv_enquetes output start====sort:3========"
    tv_enquete_ids = out_put_tv_enquetes(live_ids, id, server_name, project_name, mysql) if live_ids.present?

    #tv_questions csv导出
    output_log.info "====tv_enquetes output start====sort:3========"
    tv_question_ids=out_put_tv_questions(tv_enquete_ids, id, server_name, project_name, mysql) if tv_enquete_ids.present?

    #tv_enquete_results csv导出
    output_log.info "====tv_enquete_results output start====sort:3========"
    out_put_tv_enquete_results(live_ids,user_ids, id, server_name, project_name, mysql) if live_ids.present? && user_ids.present?

    #schedules csv导出
    output_log.info "====schedules output start====sort:3========"
    schedule_ids = out_put_schedules(id, server_name, project_name, mysql)

    #schedule_courses csv导出
    output_log.info "====schedule_courses output start====sort:3========"
    schedule_course_ids = out_put_schedule_courses(schedule_ids,course_ids,id, server_name, project_name, mysql) if schedule_ids.present? && course_ids.present?

    #schedule_user_hopes csv导出
    output_log.info "====schedule_user_hopes output start====sort:3========"
    out_put_schedule_user_hopes(schedule_course_ids,schedule_ids,user_ids,id, server_name, project_name, mysql) if schedule_ids.present? && user_ids.present? && schedule_course_ids.present?

    #favorites csv导出
    output_log.info "====favorites output start====sort:3========"
      out_put_favorites(user_ids,library_ids,subject_content_ids,exam_ids,archive_ids, id, server_name, project_name, mysql) if user_ids.present?

    #ckeditor_assets csv导出
    output_log.info "====ckeditor_assets output start====sort:3========"
    out_put_ckeditor_assets(admin_ids, id, server_name, project_name, mysql) if  admin_ids.present?
    output_log.info "====output end========"
   
   
  
  end

  # 将加盟校下的 csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw 20130705
  def self.out_put_admins(id, server_name, project_name, mysql)
    admins = []
    admin_ids = []
    #sql查找语句 并将所得值放入数组中
    mysql.query("SELECT * FROM admins where id = #{id} or (create_by_id = #{id} and type = 'TeacherAdmin')").each{|row| admins << row }
    output = FasterCSV.generate do |csv|
      line = []
      line = ["id","type","company_code","tel","fax","zip_code","address1","address2","deleted","name",
        "name2","login","email","crypted_password","salt","created_at","updated_at","remember_token",
        "remember_token_expires_at","photo_path","create_by_id","photo", "receiver_flag", "out_content_flag", "special_flag", "last_live_type"]
      csv << line
      admins.each do|admin|
        #admin is an array
        line = admin
        csv << line
        admin_ids << admin[0]
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/admins.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
    return admin_ids.join(",")
  end

  # 将当前加盟校下的users csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw 20130708
  def self.out_put_users(id, server_name, project_name, mysql)
    users = []
    uids=[]
    mysql.query("SELECT distinct users.*  FROM users LEFT OUTER JOIN purchases ON purchases.user_id = users.id LEFT OUTER JOIN school_users ON school_users.user_id = users.id WHERE (purchases.school_id = #{id} and school_users.school_id = #{id})").each{|row| users << row }
    output = FasterCSV.generate do |csv|
      line = []
      line = ["id","login","grade","company","department","office","zip_code","address1","address2","portable_email",
        "tel","sex","birthday","user_photo","self_pr","parent_login","resignation","card_num","card_validate_date",
        "card_status","memo","deleted","email","crypted_password","salt","created_at","updated_at","remember_token",
        "remember_token_expires_at","tel_mobile","enquete","pay_way","convenient_name","convenient_pay_name","convenient_pay_name_py",
        "convenient_phone","first_name","last_name","first_name_py","last_name_py","other_question","uuid_random","nickname",
        "guardian","guardian_pwd","advance_attend_time","parent_name_py","profile","receiver_flag","last_view_course_id"
      ]
      csv << line
      
      users.each do|user|
        #admin is an array
        line = user
        csv << line
        uids << user[0]
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/users.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
    return uids.join(",")
  end
  
  # 将当前加盟校下的courses csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by wxx 20130708
  def self.out_put_courses(id, server_name, project_name, mysql)
    courses = []
    cids=[]
    mysql.query("SELECT * FROM courses where school_id = #{id}").each{|row| courses << row }
    output = FasterCSV.generate do |csv|
      line = []
      line = ["id","course_id","create_id","name","price","description","open_date","close_date","pay_type","sort",
        "pay_flag","single_flag","icon_string","memo","force_flag","backgroud_flag","deleted","user_signup_items","flag","regist_displayed",
        "start_live_message","reservation_message","school_id","record_flag","layout_type","created_at","updated_at","logo","head_link_tag","lecture_start",
        "lecture_end","comment_flag","lecture_days","schedule_force_flag","inquiry_flag","material_flag","file_share_flag","schedule_order_flag","message_after_flag","show_name_flag"
      ]
      csv << line

      courses.each do|course|
        #course is an array
        line = course
        csv << line
        cids<<course[0]
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/courses.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
    return cids.join(",")
  end

  # 将当前加盟校下的school_users csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw 20130708
  def self.out_put_school_users(id, server_name, project_name, mysql)

    school_users=[]
    # sql 语句
    mysql.query("SELECT * FROM school_users where school_id=#{id} ").each{|row| school_users << row }
    output = FasterCSV.generate do |csv|
      line = []
      line = ["id","user_id","school_id","delete","created_at","updated_at","teacher_id"]
      csv << line
      school_users.each do |school_user|
        line = school_user
        csv << line
      end
    end
   
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/school_users.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
  end

  # 将当前加盟校下的user_sns csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130708
  def self.out_put_user_sns(id, user_ids, server_name, project_name, mysql)
    user_sns = []
    mysql.query("SELECT * FROM user_sns where user_id in (#{user_ids})").each{|row| user_sns << row }
    output = FasterCSV.generate do |csv|
      line = []
      line = ["id","user_id","deleted","created_at","updated_at",
        "t_access_token","t_access_token_secret","f_access_token"
      ]
      csv << line

      user_sns.each do|user_sn|
        line = user_sn
        csv << line
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/user_sns.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
  end
  # 将当前加盟校下的users_login_logs csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw 20130708
  def self.out_put_user_login_logs(id,user_ids, server_name, project_name, mysql)
    
    user_login_logs =[]
    #sql语句
    mysql.query("SELECT * FROM user_login_logs where user_id in (#{user_ids}) ").each{|row| user_login_logs << row }
    output = FasterCSV.generate do |csv|
      line = []
      line = ["id","user_id","login_at","logout_at","deleted","created_at","updated_at"]
      csv << line
      user_login_logs.each do |user_login_log|
        line = user_login_log
        csv << line
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/user_login_logs.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end

  end

  # 将当前加盟校下的course_categories csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by wxx 20130709
  def self.out_put_course_categories(id, server_name, project_name, mysql, course_ids)
    course_categories = []
    mysql.query("SELECT * FROM course_categories where course_id in (#{course_ids})").each{|row| course_categories << row }
    output = FasterCSV.generate do |csv|
      line = ["id","course_id","category_id","deleted","created_at","updated_at"]
      csv << line
      course_categories.each do|course_categorie|
        #course is an array
        line = course_categorie
        csv << line
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/course_categories.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
  end

  # 将当前加盟校下的users_login_logs csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw 20130708
  def self.out_put_free_pages(id,admin_ids, server_name, project_name, mysql)
    free_pages = []
    mysql.query("SELECT * FROM free_pages where admin_id in (#{admin_ids})").each{|row| free_pages << row }
    output = FasterCSV.generate do |csv|
      line = []
      line = ["id","category_id","name","part_flag","parent_name",
        "title","keyword","key","show","deleted","created_at","updated_at","body","admin_id","head_link_tag"
      ]
      csv << line

      free_pages.each do|free_page|
        line = free_page
        csv << line
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/free_pages.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
  end
  # 将当前加盟校下的email_templates csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130709
  def self.out_put_email_templates(id, server_name, project_name, mysql)
    email_templates = []
    e_tids=[]
    #sql 语句
    mysql.query("SELECT * FROM email_templates where create_id =#{id} ").each{|row| email_templates << row }
    output = FasterCSV.generate do |csv|
      line = []
      line = ["id","body","deleted","created_at","updated_at","title","email_type","create_id"
      ]
      csv << line

      email_templates.each do|email_template|
        line = email_template
        csv << line
        e_tids << email_template[0]
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/email_templates.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
    return e_tids.join(",")
  end

  # 将当前加盟校下的lives csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw 20130708
  def self.out_put_lives(id, server_name, project_name, mysql)
    lives = []
    live_ids = []
    # sql 语句
    mysql.query("SELECT * FROM lives where school_id=#{id} ").each{|row| lives << row }
    output = FasterCSV.generate do |csv|
      line = []
      line = ["id","exam_id","start_date","from_at","to_at","examination_open_flag","leature_file_name","leature_file_path",
        "guid","limit_num","excel_hidden_number","deleted","created_at","updated_at","name","course_id","library_id","create_id",
        "school_id","teacher_id","archive_type","record_ip","record_status","auto_flag","manual_record_status","mail_flag","view_member_count",
        "hand_record_status","special_type"
      ]
      csv << line
      lives.each do |live|
        line = live
        csv << line
        live_ids << live[0]
      end
    end

    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/lives.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
    return live_ids.join(",")
  end

  # 将当前加盟校下的setting_cols csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw 20130708
  def self.out_put_setting_cols(id, server_name, project_name, mysql)
    setting_cols = []
 
    # sql 语句
    mysql.query("SELECT * FROM setting_cols ").each{|row| setting_cols << row }
    output = FasterCSV.generate do |csv|
      line = []
      line = ["id","name","tname","fname","owner_type","width","visible","view_order","column_type","pattern",
        "created_at","updated_at"
      ]
      csv << line
      setting_cols.each do |setting_col|
        line = setting_col
        csv << line
      end
    end

    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/setting_cols.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
  end
  # 将当前加盟校下的record_servers csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw 20130708
  def self.out_put_record_servers(live_ids,id, server_name, project_name, mysql)
    record_servers = []

    # sql 语句
    mysql.query("SELECT * FROM record_servers where live_id in (#{live_ids}) ").each{|row| record_servers << row }
    output = FasterCSV.generate do |csv|
      line = []
      line = ["id","record_index","record_ip","live_id","created_at","updated_at","start_date","from_at","to_at","deleted"
      ]
      csv << line
      record_servers.each do |record_server|
        line = record_server
        csv << line
      end
    end

    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/record_servers.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end

  end
  # 将当前加盟校下的purchases csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130709
  def self.out_put_purchases(course_ids, id, server_name, project_name, mysql)
    purchases = []
    purchase_ids = []
    # sql 语句
    mysql.query("SELECT * FROM purchases where school_id = #{id} and course_id in (#{course_ids})").each{|row| purchases << row }
    output = FasterCSV.generate do |csv|
      line = []
      line = ["id","user_id","course_id","code","monthly_flag","course_name","price","course_description",
        "course_open_date","course_close_date","course_pay_type","course_sort","course_pay_flag","course_single_flag",
        "course_icon_string","course_force_flag","from_date","to_date","ajust_from_date","ajust_to_date",
        "ajust_price","relieve_flag","deleted", "created_at","updated_at","memo","school_id","manual_pay_flag",
        "create_by_admin","limit_date","signup_item1","signup_item2","signup_item3","signup_item4","signup_item5","agent_code"
      ]
      csv << line
      purchases.each do |purchase|
        line = purchase
        csv << line
        purchase_ids << purchase[0]
      end
    end

    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/purchase.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
    return purchase_ids.join(",")
  end

  # 将当前加盟校下的purchase_logs csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130709
  def self.out_put_purchase_logs(purchase_ids, id, server_name, project_name, mysql)
    purchase_logs = []
    # sql 语句
    mysql.query("SELECT * FROM purchase_logs where purchase_id in (#{purchase_ids})").each{|row| purchase_logs << row }
    output = FasterCSV.generate do |csv|
      line = []
      line = ["id","user_id","purchase_id","price","from_date","to_date","deleted",
        "created_at","updated_at","school_id","code","convenient_pay_code",
        "pay_status","confirm_status","payment_at","convenient_confirm_code",
        "memo","batch_created_at","trade_error_code"
      ]
      csv << line
      purchase_logs.each do |purchase_log|
        line = purchase_log
        csv << line
      end
    end

    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/purchase_logs.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
  end

  # 将当前加盟校下的purchase_confirm_logs csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130709
  def self.out_put_purchase_confirm_logs(id, server_name, project_name, mysql)
    purchase_confirm_logs = []
    # sql 语句
    mysql.query("SELECT * FROM purchase_confirm_logs where school_id = #{id}").each{|row| purchase_confirm_logs << row }
    output = FasterCSV.generate do |csv|
      line = []
      line = ["id","admin_id","status","year","month","deleted","created_at","updated_at","school_id",
        "confirm_at","send_at"
      ]
      csv << line
      purchase_confirm_logs.each do |purchase_confirm_log|
        line = purchase_confirm_log
        csv << line
      end
    end

    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/purchase_confirm_logs.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
  end
  # 将当前加盟校下的setting_cols csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw 20130708
  def self.out_put_force_converts(live_ids,id, server_name, project_name, mysql)
    force_converts = []

    # sql 语句
    mysql.query("SELECT * FROM force_converts where live_id in (#{live_ids}) ").each{|row| force_converts << row }
    output = FasterCSV.generate do |csv|
      line = []
      line = ["id","live_id","url","status","deleted","created_at","updated_at"
      ]
      csv << line
      force_converts.each do |force_convert|
        line = force_convert
        csv << line
      end
    end

    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/force_converts.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
  end

  # 将当前加盟校下的subjects csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by wxx 20130709
  def self.out_put_subjects(course_ids, id, server_name, project_name, mysql)
    subjects = []
    subject_ids = []
    # sql 语句
    mysql.query("SELECT * FROM subjects where course_id in (#{course_ids}) ").each{|row| subjects << row }
    output = FasterCSV.generate do |csv|
      line = []
      line = ['id', 'course_id', 'name', 'sort', 'deleted', 'memo', 'created_at', 'updated_at']
      csv << line
      subjects.each do |subject|
        csv << subject
        subject_ids << subject[0]
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/subjects.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
    return subject_ids.join(",")
  end
  # 将当前加盟校下的course_lives csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw 20130708
  def self.out_put_course_lives(course_ids,id, server_name, project_name, mysql)
    course_lives = []

    # sql 语句
    mysql.query("SELECT * FROM course_lives where course_id in (#{course_ids}) ").each{|row| course_lives << row }
    output = FasterCSV.generate do |csv|
      line = []
      line = ["id","live_id","course_id","original_live_id","deleted","created_at","updated_at"
      ]
      csv << line
      course_lives.each do |course_live|
        line = course_live
        csv << line
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/course_lives.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
   
  end

  # 将当前加盟校下的contents csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by wxx 20130709
  def self.out_put_contents(id, server_name, project_name, mysql)
    contents = []
    content_ids = []
    # sql 语句
    mysql.query("SELECT * FROM contents where school_id = #{id}").each{|row| contents << row }
    output = FasterCSV.generate do |csv|
      line = []
      line = ['id', 'name', 'file_path', 'url', 'video', 'keyword', 'memo', 'deleted', 'sort', 'video_path',
        'file_path1', 'file_path2', 'file_path3', 'school_id', 'course_id', 'homework_id', 'created_at', 'updated_at', 'android_flag', 'android_path',
        'foreign_flag', 'scorm_type', 'scorm_flag', 'out_content_flag', 'file1_name', 'file2_name', 'file3_name']
      csv << line
      contents.each do |content|
        csv << content
        content_ids << content[0]
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/contents.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
    return content_ids.join(",")
  end

  # 将当前加盟校下的subject_contents csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by wxx 20130709
  def self.out_put_subject_contents(subject_ids, id, server_name, project_name, mysql)
    subject_contents = []
    subject_content_ids = []
    # sql 语句
    mysql.query("SELECT * FROM subject_contents where subject_id in (#{subject_ids}) ").each{|row| subject_contents << row }
    output = FasterCSV.generate do |csv|
      line = ['id', 'subject_id', 'content_id', 'deleted', 'created_at', 'updated_at']
      csv << line
      subject_contents.each do |subject_content|
        csv << subject_content
        subject_content_ids << subject_content[0]
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/subject_contents.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
    return subject_content_ids.join(",")
  end

  # 将当前加盟校下的subject_study_logs csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw 20130710
  def self.out_put_subject_study_logs(subject_content_ids, subject_ids, user_ids, id, server_name, project_name, mysql)
    subject_study_logs = []
    # sql 语句
    mysql.query("SELECT * FROM subject_study_logs where subject_content_id in (#{subject_content_ids}) and subject_id in (#{subject_ids}) and user_id in (#{user_ids}) ").each{|row| subject_study_logs << row }
    output = FasterCSV.generate do |csv|
      line = ['id', 'subject_content_id', 'subject_id', 'user_id', 'deleted', 'created_at', 'updated_at', 'model', 'account']
      csv << line
      subject_study_logs.each do |subject_study_log|
        csv << subject_study_log
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/subject_study_logs.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
  end
  # 将当前加盟校下的live_urls csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw 20130710
  def self.out_put_lives_urls(live_ids, id, server_name, project_name, mysql)
    lives_urls = []

    # sql 语句
    mysql.query("SELECT * FROM live_urls where live_id in (#{live_ids}) ").each{|row| lives_urls << row }
    output = FasterCSV.generate do |csv|
      line = []
      line = ["id","live_id","url","proxy_flag","deleted","created_at","updated_at"
      ]
      csv << line
      lives_urls.each do |lives_url|
        line = lives_url
        csv << line
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/lives_urls.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end

  end
  # 将当前加盟校下的iframe_urls csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw 20130710
  def self. out_put_iframe_urls(live_ids, id, server_name, project_name, mysql)
    iframe_urls = []

    # sql 语句
    mysql.query("SELECT * FROM iframe_urls where live_id in (#{live_ids}) ").each{|row| iframe_urls << row }
    output = FasterCSV.generate do |csv|
      line = []
      line = ["id","live_id","url","scroll_x","scroll_y","deleted","created_at","updated_at","https_flag","proxy_flag"
      ]
      csv << line
      iframe_urls.each do |iframe_url|
        line = iframe_url
        csv << line
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/iframe_urls.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
  end

  # 将当前加盟校下的live_users csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw 20130710
  def self.out_put_live_users(user_ids,live_ids, id, server_name, project_name, mysql)
    live_users = []

    # sql 语句
    mysql.query("SELECT * FROM live_users where live_id in (#{live_ids}) and user_id in (#{user_ids}) ").each{|row| live_users << row }
    output = FasterCSV.generate do |csv|
      line = []
      line = ["id","user_id","live_id","deleted","created_at","updated_at"
      ]
      csv << line
      live_users.each do |live_user|
        line = live_user
        csv << line
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/live_users.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
  end

  # 将当前加盟校下的homeworks csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130710
  def self.out_put_homeworks(course_ids, id, server_name, project_name, mysql)
    homeworks = []
    homework_ids = []
    # sql 语句
    mysql.query("SELECT * FROM homeworks where course_id in (#{course_ids}) ").each{|row| homeworks << row }
    output = FasterCSV.generate do |csv|
      line = []
      line = [ "id","course_id","deleted","created_at","updated_at","comment","title"
      ]
      csv << line
      homeworks.each do |homework|
        line = homework
        csv << line
        homework_ids << homework[0]
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/homeworks.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
    return homework_ids.join(",")
  end

  # 将当前加盟校下的contact_courses csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130710
  def self.out_put_contact_courses(course_ids, id, server_name, project_name, mysql)
    contact_courses = []
    # sql 语句
    mysql.query("SELECT * FROM contact_courses where course_id in (#{course_ids}) ").each{|row| contact_courses << row }
    output = FasterCSV.generate do |csv|
      line = []
      line = [ "id","course_id","contact_course_id","deleted","created_at","updated_at","show_stream"
      ]
      csv << line
      contact_courses.each do |contact_course|
        line = contact_course
        csv << line
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/contact_courses.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
  end

  # 将当前加盟校下的libraries csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by wxx 20130711
  def self.out_put_libraries(course_ids, id, server_name, project_name, mysql)
    libraries = []
    library_ids = []
    # sql 语句
    mysql.query("SELECT * FROM libraries where course_id in (#{course_ids}) ").each{|row| libraries << row }
    output = FasterCSV.generate do |csv|
      line = ['id', 'course_id', 'title', 'file_name', 'file_path', 'deleted', 'created_at', 'updated_at', 'open_status', 'url', 'memo', 'sort']
      csv << line
      libraries.each do |library|
        line = library
        csv << line
        library_ids << library[0]
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/libraries.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
    return library_ids.join(",")
  end

  # 将当前加盟校下的view_members csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw 20130711
  def self.out_put_view_members(live_ids,user_ids, id, server_name, project_name, mysql)
    view_members = []

    # sql 语句
    mysql.query("SELECT * FROM view_members where live_id in (#{live_ids}) and user_id in (#{user_ids}) ").each{|row| view_members << row }
    output = FasterCSV.generate do |csv|
      line = []
      line = ["id","user_id","live_id","deleted","created_at","updated_at"
      ]
      csv << line
      view_members.each do |view_member|
        line = view_member
        csv << line
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/view_members.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
  end

  # 将当前加盟校下的live_user_hopes csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw 20130711

  def self.out_put_live_user_hopes(live_ids,user_ids, id, server_name, project_name, mysql)
    live_user_hopes = []

    # sql 语句
    mysql.query("SELECT * FROM live_user_hopes where live_id in (#{live_ids}) and user_id in (#{user_ids}) ").each{|row| live_user_hopes << row }
    output = FasterCSV.generate do |csv|
      line = []
      line = ["id","user_id","live_id","deleted","created_at","updated_at","attend_status","course_live_id","mail_flag",
        "force_cancel","leave_flag"
      ]
      csv << line
      live_user_hopes.each do |live_user_hope|
        line = live_user_hope
        csv << line
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/live_user_hopes.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
  end

  # 将当前加盟校下的exams csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by wxx 20130711
  def self.out_put_exams(course_ids, id, server_name, project_name, mysql)
    exams = []
    exam_ids = []
    # sql 语句
    mysql.query("SELECT * FROM exams where course_id in (#{course_ids}) ").each{|row| exams << row }
    output = FasterCSV.generate do |csv|
      line = ['id', 'course_id', 'live_id', 'name', 'status', 'deleted', 'created_at', 'updated_at', 'sort', 'eligible']
      csv << line
      exams.each do |exam|
        line = exam
        csv << line
        exam_ids << exam[0]
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/exams.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
    return exam_ids.join(",")
  end
 
  # 将当前加盟校下的exam_result_totals csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by wxx 20130711
  def self.out_put_exam_result_totals(user_ids, exam_ids, id, server_name, project_name, mysql)
    exam_result_totals = []
    exam_result_total_ids = []
    # sql 语句
    mysql.query("SELECT * FROM exam_result_totals where user_id in (#{user_ids}) and exam_id in (#{exam_ids}) ").each{|row| exam_result_totals << row }
    output = FasterCSV.generate do |csv|
      line = ['id', 'user_id', 'exam_id', 'all_total_score', 'created_at', 'updated_at']
      csv << line
      exam_result_totals.each do |exam_result_total|
        line = exam_result_total
        csv << line
        exam_result_total_ids << exam_result_total[0]
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/exam_result_totals.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
    return exam_result_total_ids.join(",")
  end

  # 将当前加盟校下的exam_titles csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by wxx 20130711
  def self.out_put_exam_titles(exam_ids, id, server_name, project_name, mysql)
    exam_titles = []
    exam_title_ids = []
    # sql 语句
    mysql.query("SELECT * FROM exam_titles where exam_id in (#{exam_ids}) ").each{|row| exam_titles << row }
    output = FasterCSV.generate do |csv|
      line = ['id', 'exam_id', 'title', 'content', 'deleted', 'created_at', 'updated_at', 'sort']
      csv << line
      exam_titles.each do |exam_title|
        line = exam_title
        csv << line
        exam_title_ids << exam_title[0]
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/exam_titles.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
    return exam_title_ids.join(",")
  end

  # 将当前加盟校下的exam_results csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by wxx 20130711
  def self.out_put_exam_results(user_ids, exam_ids, id, server_name, project_name, mysql)
    exam_results = []
    exam_result_ids = []
    # sql 语句
    mysql.query("SELECT * FROM exam_results where user_id in (#{user_ids}) and exam_id in (#{exam_ids}) ").each{|row| exam_results << row }
    output = FasterCSV.generate do |csv|
      line = ['id', 'user_id', 'exam_id', 'total_score', 'deleted', 'created_at', 'updated_at', 'exam_title_id', 'exam_result_total_id']
      csv << line
      exam_results.each do |exam_result|
        line = exam_result
        csv << line
        exam_result_ids << exam_result[0]
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/exam_results.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
    return exam_result_ids.join(",")
  end

  # 将当前加盟校下的comments csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130711
  def self.out_put_comments(user_ids, course_ids, id, server_name, project_name, mysql)
    comments = []
    # sql 语句
    mysql.query("SELECT * FROM comments where school_id = #{id} and user_id in (#{user_ids}) and course_id in (#{course_ids}) ").each{|row| comments << row }
    output = FasterCSV.generate do |csv|
      line = ["id",  "user_id",  "course_id", " school_id",  "content",  "deleted",  "created_at",  "updated_at",  "facebook_flag",  "twitter_flag",  "mixi_flag" ]
      csv << line
      comments.each do |comment|
        line = comment
        csv << line
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/comments.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
  end

  # 将当前加盟校下的course_email_temps  csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130711
  def self.out_put_course_email_temps(course_ids, id, server_name, project_name, mysql)
    course_email_temps  = []
    # sql 语句
    mysql.query("SELECT * FROM course_email_temps where course_id in (#{course_ids}) ").each{|row| course_email_temps << row }
    output = FasterCSV.generate do |csv|
      line = ["id",  "course_id", " email_template_id",  "deleted",  "created_at",  "updated_at"]
      csv << line
      course_email_temps.each do |course_email_temp|
        line = course_email_temp
        csv << line
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/course_email_temps.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
  end

  # 将当前加盟校下的inquiries  csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130711
  def self.out_put_inquiries( id, server_name, project_name, mysql)
    inquiries  = []
    # sql 语句
    mysql.query("SELECT * FROM inquiries where school_id = #{id} ").each{|row| inquiries << row }
    output = FasterCSV.generate do |csv|
      line = ["id",  "course_id",  "user_id", "content",  "answer",  "flag",  "deleted",  "created_at",
        "updated_at",  "school_id",  "tel",  "company",  "department",  "office",  "first_name",  "first_name_py",
        "last_name",  "last_name_py",  "sex",  "zip_code",  "address1",  "address2",  "email",  "answer_flag"]
      csv << line
      inquiries.each do |inquiry|
        line = inquiry
        csv << line
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/inquiries.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
  end

  # 将当前加盟校下的infos  csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130711
  def self.out_put_infos(admin_ids, id, server_name, project_name, mysql)
    infos  = []
    info_ids = []
    # sql 语句
    mysql.query("SELECT * FROM infos where created_id in (#{admin_ids}) ").each{|row| infos << row }
    output = FasterCSV.generate do |csv|
      line = ["id",  "start_date",  "end_date",  "title",  "content",  "view_flag",  "memo",  "deleted",  "created_at",  "updated_at",
        "course_id",  "send_before_login",  "send_logined",  "send_backstage",  "created_id",  "send_school",  "send_teacher",
        "send_user",  "send_parent" ]
      csv << line
      infos.each do |info|
        line = info
        csv << line
        info_ids << info[0]
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/infos.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
    return info_ids.join(",")
  end

  # 将当前加盟校下的course_infos  csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130711
  def self.out_put_course_infos(info_ids, course_ids, id, server_name, project_name, mysql)
    course_infos  = []
    # sql 语句
    mysql.query("SELECT * FROM course_infos where info_id in (#{info_ids}) and course_id in (#{course_ids})").each{|row| course_infos << row }
    output = FasterCSV.generate do |csv|
      line = ["id",  "course_id",  "info_id", "deleted",  "created_at", "updated_at" ]
      csv << line
      course_infos.each do |course_info|
        line = course_info
        csv << line
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/course_infos.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
  end

  # 将当前加盟校下的exam_questions csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by wxx 20130712
  def self.out_put_exam_questions(exam_ids, exam_title_ids, id, server_name, project_name, mysql)
    exam_questions  = []
    exam_question_ids = []
    # sql 语句
    mysql.query("SELECT * FROM exam_questions where exam_id in (#{exam_ids}) or exam_title_id in (#{exam_title_ids}) ").each{|row| exam_questions << row }
    output = FasterCSV.generate do |csv|
      line = ['id', 'exam_id', 'sort', 'code', 'title', 'question_type', 'description', 'explanation', 'score', 'deleted', 'created_at', 'updated_at', 'exam_title_id']
      csv << line
      exam_questions.each do |exam_question|
        line = exam_question
        csv << line
        exam_question_ids << exam_question[0]
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/exam_questions.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
    return exam_question_ids.join(",")
  end

  # 将当前加盟校下的exam_result_details csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by wxx 20130712
  def self.out_put_exam_result_details(exam_result_ids, exam_question_ids, id, server_name, project_name, mysql)
    exam_result_details  = []
    exam_result_detail_ids = []
    # sql 语句
    mysql.query("SELECT * FROM exam_result_details where exam_result_id in (#{exam_result_ids}) and exam_question_id in (#{exam_question_ids}) ").each{|row| exam_result_details << row }
    output = FasterCSV.generate do |csv|
      line = ['id', 'exam_result_id', 'exam_question_id', 'answer_choice_ids', 'scoce', 'answer_detail', 'deleted', 'created_at', 'updated_at']
      csv << line
      exam_result_details.each do |exam_result_detail|
        line = exam_result_detail
        csv << line
        exam_result_detail_ids << exam_result_detail[0]
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/exam_result_details.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
   
    return exam_result_detail_ids.join(",")
  end

  # 将当前加盟校下的exam_question_choices csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by wxx 20130712
  def self.out_put_exam_question_choices(exam_question_ids, id, server_name, project_name, mysql)
    exam_question_choices  = []
    exam_question_choice_ids = []
    # sql 语句
    mysql.query("SELECT * FROM exam_question_choices where exam_question_id in (#{exam_question_ids}) ").each{|row| exam_question_choices << row }
    output = FasterCSV.generate do |csv|
      line = ['id', 'exam_question_id', 'content', 'correct', 'deleted', 'created_at', 'updated_at', 'photo_path']
      csv << line
      exam_question_choices.each do |exam_question_choice|
        line = exam_question_choice
        csv << line
        exam_question_choice_ids << exam_question_choices[0]
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/exam_question_choices.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
    #    return exam_question_choice_ids.join(",")
  end
  # 将当前加盟校下的tv_action_logs csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw 20130712
  def self.out_put_tv_action_logs(live_ids,user_ids, id, server_name, project_name, mysql)
    tv_action_logs  = []
    # sql 语句
    user_ids = user_ids.split(",") if user_ids.present?
    mysql.query("SELECT * FROM tv_action_logs where live_id in (#{live_ids}) ").each{|row| tv_action_logs << row }
    output = FasterCSV.generate do |csv|
      line = ["id",  "live_id",  "uid", "role", "mode",  "sta_end", "deleted",  "created_at", "updated_at","content", "obj_id" ]
      csv << line
      
      tv_action_logs.each do |tv_action_log|
        #        if tv_action_log[3] == "student" && user_ids.include?(tv_action_log[10].to_s)
        line = tv_action_log
        csv << line
        #        elsif tv_action_log[3] != "student"
        #          line = tv_action_log
        #          csv << line
        #        end
      
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/tv_action_logs.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end

  end
  # 将当前加盟校下的tv_chat_logs csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw 20130712
  def self.out_put_tv_chat_logs(live_ids,user_ids, id, server_name, project_name, mysql)
    tv_chat_logs  = []
    # sql 语句
    user_ids = user_ids.split(",") if user_ids.present?
    mysql.query("SELECT * FROM tv_chat_logs where live_id in (#{live_ids}) ").each{|row| tv_chat_logs << row }
    output = FasterCSV.generate do |csv|
      line = ["id",  "live_id",  "uid", "role", "mode", "content", "sta_end", "deleted",  "created_at", "updated_at", "obj_id" ]
      csv << line

      tv_chat_logs.each do |tv_chat_log|
        #        if tv_chat_log[3] == "student" && user_ids.include?(tv_chat_log[10].to_s)
        line = tv_chat_log
        csv << line
        #        elsif tv_chat_log[3] != "student"
        #          line = tv_chat_log
        #          csv << line
        #        end

      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/tv_chat_logs.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
  end
  # 将当前加盟校下的tv_chat_logs csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw 20130712
  def self.out_put_tv_file_sends(live_ids, id, server_name, project_name, mysql)
    tv_file_sends  = []
    # sql 语句
    mysql.query("SELECT * FROM tv_file_sends where live_id in (#{live_ids}) ").each{|row| tv_file_sends << row }
    output = FasterCSV.generate do |csv|
      line = ["id",  "from_id",  "from_role", "to_id", "to_role", "content", "file_name","file_path", "deleted",  "created_at", "updated_at", "from_uid",
        "to_uid","mode","live_id","capture_target" ]
      csv << line

      tv_file_sends.each do |tv_file_send|
        line = tv_file_send
        csv << line
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/tv_file_sends.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
    
  end

  # 将当前加盟校下的tv_layouts csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw 20130712
  def self.out_put_tv_layouts(live_ids, id, server_name, project_name, mysql)
    tv_layouts  = []
    # sql 语句
    mysql.query("SELECT * FROM tv_layouts where live_id in (#{live_ids}) ").each{|row| tv_layouts << row }
    output = FasterCSV.generate do |csv|
      line = ["id",  "live_id",  "created_date", "title", "lecturer_left", "lecturer_right", "student_left","student_right", 
        "videolist_colspan",  "videolist", "videopickup_colspan", "videopickup", "deleted","created_at","updated_at" ]
      csv << line

      tv_layouts.each do |tv_layout|
        line = tv_layout
        csv << line
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/tv_layouts.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
  end
  # 将当前加盟校下的tv_status csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw 20130712
  def self.out_put_tv_status(live_ids,user_ids, id, server_name, project_name, mysql)
    tv_status = []
    # sql 语句
    user_ids = user_ids.split(",") if user_ids.present?
    mysql.query("SELECT * FROM tv_status where live_id in (#{live_ids}) ").each{|row| tv_status << row }
    output = FasterCSV.generate do |csv|
      line = ["id",  "live_id",  "uid", "role", "video", "mic", "volume","whiteboard",
        "read_flag","evicted", "deleted",  "created_at", "updated_at", "obj_id" ]
      csv << line

      tv_status.each do |tv_statu|
        #        if tv_statu[3] == "student" && user_ids.include?(tv_statu[13].to_s)
        line = tv_statu
        csv << line
        #        elsif tv_status[3] != "student"
        #          line = tv_statu
        #          csv << line
        #        end

      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/tv_status.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end

  end

  # 将当前加盟校下的enquetes csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130712
  def self.out_put_enquetes(admin_ids ,id, server_name, project_name, mysql)
    enquetes = []
    enquete_ids = []
    # sql 语句
    mysql.query("SELECT * FROM enquetes where created_id in (#{admin_ids}) ").each{|row| enquetes << row }
    output = FasterCSV.generate do |csv|
      line = ["id",  "course_id", "live_id",  "name", "status", "sort", "deleted",  "created_at", "updated_at", "created_id" ]
      csv << line

      enquetes.each do |enquete|
        line = enquete
        csv << line
        enquete_ids << enquete[0]

      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/enquetes.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
    return enquete_ids.join(",")
  end

  # 将当前加盟校下的enquete_results csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130712
  def self.out_put_enquete_results(enquete_ids, user_ids, id, server_name, project_name, mysql)
    enquete_results = []
    enquete_result_ids = []
    # sql 语句
    mysql.query("SELECT * FROM enquete_results where user_id in (#{user_ids}) and enquete_id in (#{enquete_ids}) ").each{|row| enquete_results << row }
    output = FasterCSV.generate do |csv|
      line = ["id",  "user_id", "enquete_id",  "total_score", "deleted",  "created_at", "updated_at" ]
      csv << line

      enquete_results.each do |enquete_result|
        line = enquete_result
        csv << line
        enquete_result_ids << enquete_result[0]

      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/enquete_results.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
    return enquete_result_ids.join(",")
  end

  # 将当前加盟校下的enquete_users csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130712
  def self.out_put_enquete_users(enquete_ids, user_ids, id, server_name, project_name, mysql)
    enquete_users = []
    # sql 语句
    mysql.query("SELECT * FROM enquete_users where user_id in (#{user_ids}) and enquete_id in (#{enquete_ids}) ").each{|row| enquete_users << row }
    output = FasterCSV.generate do |csv|
      line = ["id",  "enquete_id", "user_id", "deleted",  "created_at", "updated_at" ]
      csv << line

      enquete_users.each do |enquete_user|
        line = enquete_user
        csv << line
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/enquete_users.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
  end

  # 将当前加盟校下的enquete_courses csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130712
  def self.out_put_enquete_courses(enquete_ids, course_ids, id, server_name, project_name, mysql)
    enquete_courses = []
    # sql 语句
    mysql.query("SELECT * FROM enquete_courses where course_id in (#{course_ids}) and enquete_id in (#{enquete_ids}) ").each{|row| enquete_courses << row }
    output = FasterCSV.generate do |csv|
      line = ["id",  "enquete_id", "course_id", "deleted",  "created_at", "updated_at" ]
      csv << line

      enquete_courses.each do |enquete_course|
        line = enquete_course
        csv << line
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/enquete_courses.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
  end

  # 将当前加盟校下的enquete_questions csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130712
  def self.out_put_enquete_questions(enquete_ids, id, server_name, project_name, mysql)
    enquete_questions = []
    enquete_question_ids = []
    # sql 语句
    mysql.query("SELECT * FROM enquete_questions where enquete_id in (#{enquete_ids}) ").each{|row| enquete_questions << row }
    output = FasterCSV.generate do |csv|
      line = ["id",  "enquete_id", "sort","code","title","question_type","description","explanation","score",
        "deleted",  "created_at", "updated_at","stats" ]
      csv << line

      enquete_questions.each do |enquete_question|
        line = enquete_question
        csv << line
        enquete_question_ids << enquete_question[0]
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/enquete_questions.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
    return enquete_question_ids.join(",")
  end

  # 将当前加盟校下的enquete_questions_choices csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130712
  def self.out_put_enquete_questions_choices(enquete_question_ids, id, server_name, project_name, mysql)
    enquete_questions_choices = []
    # sql 语句
    mysql.query("SELECT * FROM enquete_question_choices where enquete_question_id in (#{enquete_question_ids}) ").each{|row| enquete_questions_choices << row }
    output = FasterCSV.generate do |csv|
      line = ["id",  "enquete_question_id", "content","correct", "deleted",  "created_at", "updated_at","photo_path" ]
      csv << line

      enquete_questions_choices.each do |enquete_questions_choice|
        line = enquete_questions_choice
        csv << line
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/enquete_questions_choices.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
  end

  # 将当前加盟校下的enquete_result_details csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130712
  def self.out_put_enquete_result_details(enquete_result_ids, enquete_question_ids, id, server_name, project_name, mysql)
    enquete_result_details = []
    # sql 语句
    mysql.query("SELECT * FROM enquete_result_details where enquete_result_id in (#{enquete_result_ids}) and enquete_question_id in (#{enquete_question_ids}) ").each{|row| enquete_result_details << row }
    output = FasterCSV.generate do |csv|
      line = ["id",  "enquete_result_id", "enquete_question_id","scoce","answer_choice_ids","answer_detail",
        "deleted",  "created_at", "updated_at"]
      csv << line

      enquete_result_details.each do |enquete_result_detail|
        line = enquete_result_detail
        csv << line
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/enquete_result_details.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
  end

  # 将当前加盟校下的course_teachers csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130712
  def self.out_put_course_teachers(course_ids, admin_ids, id, server_name, project_name, mysql)
    course_teachers = []
    # sql 语句
    mysql.query("SELECT * FROM course_teachers where course_id in (#{course_ids}) and teacher_id in (#{admin_ids}) and school_id = #{id}  ").each{|row| course_teachers << row }
    output = FasterCSV.generate do |csv|
      line = ["id",  "course_id", "school_id","teacher_id","mailsend_flag","created_at", "updated_at","deleted"]
      csv << line

      course_teachers.each do |course_teacher|
        line = course_teacher
        csv << line
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/course_teachers.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
  end

  # 将当前加盟校下的archives csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130712
  def self.out_put_archives(live_ids, id, server_name, project_name, mysql)
    archives = []
    archive_ids = []
    # sql 语句
    mysql.query("SELECT * FROM archives where live_id in (#{live_ids})").each{|row| archives << row }
    output = FasterCSV.generate do |csv|
      line = ["id",  "live_id", "name","path","guid","deleted","created_at", "updated_at","show_status","teacher_type"]
      csv << line

      archives.each do |archive|
        line = archive
        csv << line
        archive_ids << archive[0]
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/archives.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
    return archive_ids.join(",")
  end

  # 将当前加盟校下的file_shares csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130712
  def self.out_put_file_shares(admin_ids, user_ids,course_ids, id, server_name, project_name, mysql)
    file_shares = []
    file_share_ids = []
    # sql 语句
    mysql.query("SELECT * FROM file_shares where ((type = 'FileStudent' and user_id in (#{user_ids})) or (type = 'FileTeacher' and user_id in (#{admin_ids}))) or course_id in (#{course_ids})").each{|row| file_shares << row }
    output = FasterCSV.generate do |csv|
      line = ["id", "course_ids", "user_id","type","title","content","sender_flag","file_path","file_name", "deleted","created_at", "updated_at"]
      csv << line

      file_shares.each do |file_share|
        line = file_share
        csv << line
        file_share_ids << file_share[0]
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/file_shares.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
    return file_share_ids.join(",")
  end

  # 将当前加盟校下的file_share_replies csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130712
  def self.out_put_file_share_replies(admin_ids ,user_ids,file_share_ids, id, server_name, project_name, mysql)
    file_share_replies = []
    # sql 语句
    mysql.query("SELECT * FROM file_share_replies where ((type = 'FileStudentReply' and user_id in (#{user_ids})) or (type = 'FileTeacherReply' and user_id in (#{admin_ids}))) and file_share_id in (#{file_share_ids})").each{|row| file_share_replies << row }
    output = FasterCSV.generate do |csv|
      line = ["id", "file_share_id", "user_id","type","title","content","sender_flag","file_path","file_name", "deleted","created_at", "updated_at"]
      csv << line

      file_share_replies.each do |file_share_reply|
        line = file_share_reply
        csv << line
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/file_share_replies.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
  end

  # 将当前加盟校下的lms_scorms csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130712
  def self.out_put_lms_scorms(content_ids ,id, server_name, project_name, mysql)
    lms_scorms = []
    lms_scorm_ids = []
    # sql 语句
    mysql.query("SELECT * FROM lms_scorms where content_id in (#{content_ids})").each{|row| lms_scorms << row }
    output = FasterCSV.generate do |csv|
      line = ["id", "content_id", "zip_path","zip_file_name","unzip_file_path","unzip_file_path","mod", "deleted","created_at", "updated_at","subject_id"]
      csv << line

      lms_scorms.each do |lms_scorm|
        line = lms_scorm
        csv << line
        lms_scorm_ids << lms_scorm[0]
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/lms_scorms.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
    return lms_scorm_ids.join(",")
  end

  # 将当前加盟校下的user_scorms csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130712
  def self.out_put_user_scorms( lms_scorm_ids, id, server_name, project_name, mysql)
    user_scorms = []
    # sql 语句
    mysql.query("SELECT * FROM user_scorms where lms_scorm_id in (#{lms_scorm_ids})").each{|row| user_scorms << row }
    output = FasterCSV.generate do |csv|
      line = ["id", "user_id", "content_id", "lms_scorm_id", "lesson_status","score","session_time", "deleted","created_at", "updated_at"]
      csv << line

      user_scorms.each do |user_scorm|
        line = user_scorm
        csv << line
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/user_scorms.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
  end

  # 将当前加盟校下的scorm_study_logs csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130712
  def self.out_put_scorm_study_logs( lms_scorm_ids, id, server_name, project_name, mysql)
    scorm_study_logs = []
    # sql 语句
    mysql.query("SELECT * FROM scorm_study_logs where scorm_id in (#{lms_scorm_ids})").each{|row| scorm_study_logs << row }
    output = FasterCSV.generate do |csv|
      line = ["id",  "content_id", "scorm_id","user_id", "listen_flag", "deleted","created_at", "updated_at","subject_id"]
      csv << line

      scorm_study_logs.each do |scorm_study_log|
        line = scorm_study_log
        csv << line
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/scorm_study_logs.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
  end

  # 将当前加盟校下的ckeditor_assets csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130712
  def self.out_put_ckeditor_assets(admin_ids, id, server_name, project_name, mysql)
    ckeditor_assets = []
    # sql 语句
    mysql.query("SELECT * FROM ckeditor_assets where user_id in (#{admin_ids})").each{|row| ckeditor_assets << row }
    output = FasterCSV.generate do |csv|
      line = ["id",  "data_file_name", "data_content_type","data_file_size","assetable_id", "assetable_type", "type","guid","locale","user_id", "created_at", "updated_at"]
      csv << line

      ckeditor_assets.each do |ckeditor_asset|
        line = ckeditor_asset
        csv << line
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/ckeditor_assets.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
  end

  # 将当前加盟校下的tv_streams csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw 20130712
  def self.out_put_tv_streams(live_ids,user_ids, id, server_name, project_name, mysql)
    tv_streams = []
    # sql 语句
    user_ids = user_ids.split(",") if user_ids.present?
    mysql.query("SELECT * FROM tv_streams where live_id in (#{live_ids}) ").each{|row| tv_streams << row }
    output = FasterCSV.generate do |csv|
      line = ["id",  "live_id",  "uid", "role", "bandwidth", "fps", "camerawidth","cameraheight",
        "rate","silencelevel","gain", "deleted",  "created_at", "updated_at", "obj_id" ]
      csv << line

      tv_streams.each do |tv_stream|
        #        if tv_stream[3] == "student" && user_ids.include?(tv_stream[14].to_s)
        line = tv_stream
        csv << line
        #        elsif tv_stream[3] != "student"
        #          line = tv_stream
        #          csv << line
        #        end

      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/tv_streams.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
  end

  # 将当前加盟校下的tv_enquetes csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw 20130712
  def self.out_put_tv_enquetes(live_ids, id, server_name, project_name, mysql)
    tv_enquetes  = []
    tv_enquete_ids=[]
    # sql 语句
    mysql.query("SELECT * FROM tv_enquetes where live_id in (#{live_ids}) ").each{|row| tv_enquetes << row }
    output = FasterCSV.generate do |csv|
      line = ["id",  "live_id",  "title", "description", "open_flag", "create_date",  "deleted","created_at","updated_at","obj_id" ]
      csv << line

      tv_enquetes.each do |tv_enquete|
        line = tv_enquete
        tv_enquete_ids << tv_enquete[0]
        csv << line
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/tv_enquetes.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
    return tv_enquete_ids.join(",")
  end
  # 将当前加盟校下的tv_questions csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw 20130712
  def self.out_put_tv_questions(tv_enquete_ids, id, server_name, project_name, mysql)
    tv_questions  = []
    tv_question_ids=[]
    # sql 语句
    mysql.query("SELECT * FROM tv_questions where tv_enquete_id in (#{tv_enquete_ids}) ").each{|row| tv_questions << row }
    output = FasterCSV.generate do |csv|
      line = ["id",  "tv_enquete_id",  "title", "description", "show_order","deleted", "create_date",  "updated_at" ]
      csv << line

      tv_questions.each do |tv_question|
        line = tv_question
        tv_question_ids << tv_question[0]
        csv << line
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/tv_questions.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
    return tv_question_ids.join(",")
  end

  # 将当前加盟校下的tv_enquete_results csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw 20130712
  def self.out_put_tv_enquete_results(live_ids,user_ids, id, server_name, project_name, mysql)
    tv_enquete_results = []
    # sql 语句
    user_ids = user_ids.split(",") if user_ids.present?
    mysql.query("SELECT * FROM tv_enquete_results where live_id in (#{live_ids}) ").each{|row| tv_enquete_results << row }
    output = FasterCSV.generate do |csv|
      line = ["id",  "tv_enquete_id",  "tv_question_id", "tv_choice_id", "user_id", "live_id", "memo", "deleted",  "created_at", "updated_at", "uid" ]
      csv << line
      tv_enquete_results.each do |tv_enquete_result|
        #        uid = tv_enquete_result[10].delete("student")
        #        if user_ids.include?(uid)
        line = tv_enquete_result
        csv << line
        #        end
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/tv_enquete_results.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end

  end

  # 将当前加盟校下的favorites csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw 20130712
  def self.out_put_favorites(user_ids,library_ids,subject_content_ids,exam_ids,archive_ids, id, server_name, project_name, mysql)
    favorites = []
    # sql 语句
    mysql.query("SELECT * FROM favorites where user_id in (#{user_ids}) ").each{|row| favorites << row }
    subject_content_ids = subject_content_ids.split(",") if subject_content_ids.present?
    library_ids = library_ids.split(",") if library_ids.present?
    archive_ids = archive_ids.split(",") if archive_ids.present?
    exam_ids = exam_ids.split(",") if exam_ids.present?
    output = FasterCSV.generate do |csv|
      line = ["id",  "user_id",  "deleted",  "created_at", "updated_at", "type","obj_id" ]
      csv << line
      favorites.each do |favorite|
        obj_id = favorite[6]
        if favorite[5] == "SubjectContentFavorite" && subject_content_ids.include?(obj_id)
          line = favorite
          csv << line
        elsif favorite[5] == "LibraryFavorite" && library_ids.include?(obj_id)
          line = favorite
          csv << line
        elsif favorite[5] == "ArchiveFavorite" && archive_ids.include?(obj_id)
          line = favorite
          csv << line
        elsif favorite[5] == "ExamFavorite" && exam_ids.include?(obj_id)
          line = favorite
          csv << line
        end
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/favorites.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end

  end

  # 将当前加盟校下的tags csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw 20130712
  def self.out_put_tags( id, server_name, project_name, mysql, tagging_ids)
    tags = []
    tag_ids = []
    # sql 语句
    mysql.query("SELECT * FROM tags where id in (#{tagging_ids})").each{|row| tags << row }
    output = FasterCSV.generate do |csv|
      line = ["id",  "name" ]
      csv << line
      tags.each do |tag|
        line = tag
        tag_ids << tag[0]
        csv << line
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/tags.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
   
    return tag_ids.join(",")
  end

  # 将当前加盟校下的mess_groups csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130716
  def self.out_put_mess_groups( id, server_name, project_name, mysql)
    mess_groups = []
    mess_group_ids = []
    #sql语句
    mysql.query("SELECT * FROM mess_groups where school_id = #{id}").each{|row| mess_groups << row}
    output = FasterCSV.generate do |csv|
      line = ["id","name","memo","delete","created_at","updated_at","teacher_id","school_id"]
      csv << line
      mess_groups.each do |mess_group|
        line = mess_group
        csv << line
        mess_group_ids << mess_group[0]
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/mess_groups.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
    return mess_group_ids.join(",")
  end

  # 将当前加盟校下的user_groups csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130716
  def self.out_put_user_groups(mess_group_ids, id, server_name, project_name, mysql)
    user_groups = []
    # sql 语句
    mysql.query("SELECT * FROM user_groups where mess_group_id in (#{mess_group_ids})").each{|row| user_groups << row }
    output = FasterCSV.generate do |csv|
      line = ["id",  "mess_group_id","user_id","deleted","created_at","updated_at" ]
      csv << line
      user_groups.each do |user_group|
        line = user_group
        csv << line
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/user_groups.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
  end

  # 将当前加盟校下的message_folders csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130716
  def self.out_put_message_folders(admin_ids,user_ids, id, server_name, project_name, mysql)
    message_folders = []
    message_folder_ids = []
    # sql 语句
    if admin_ids.present?
      mysql.query("SELECT * FROM message_folders where admin_id in (#{admin_ids})").each{|row| message_folders << row }
    end
    if user_ids.present?
      mysql.query("SELECT * FROM message_folders where  user_id in (#{user_ids})").each{|m| message_folders << m}
    end
    output = FasterCSV.generate do |csv|
      line = ["id",  "name","deleted","created_at","updated_at","admin_id","user_id","sender" ]
      csv << line
      message_folders.each do |message_folder|
        line = message_folder
        csv << line
        message_folder_ids << message_folder[0]
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/message_folders.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
    return message_folder_ids.join(",")
  end

  # 将当前加盟校下的messages csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130716
  def self.out_put_messages(admin_ids,user_ids,message_folder_ids,course_ids, id, server_name, project_name, mysql)
    messages = []
    message_ids = []
    # sql 语句
    if admin_ids.present?
      mysql.query("SELECT * FROM messages where admin_id in (#{admin_ids})  ").each{|row| messages << row }
    end
    if user_ids.present?
      mysql.query("SELECT * FROM messages where  user_id in (#{user_ids}) ").each{|m| messages << m }
    end
    counter = 0
    output = FasterCSV.generate do |csv|
      line = ["id",  "user_id","admin_id","title","content","deleted", "created_at","updated_at","rubbish","course_id","draft","sender","mess_groups","old_id","old_message_folder_id" ]
      csv << line
      messages.each do |message|
        p '----------------------'
        p counter
        p '----------------------'
        line = message.push((counter += 1).to_s)
        csv << line
        message_ids << message[0]
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/messages.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
    return message_ids.join(",")
  end

  # 将当前加盟校下的receivers csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130716
  def self.out_put_receivers(message_ids, id, server_name, project_name, mysql)
    receivers = []
    # sql 语句
    mysql.query("SELECT * FROM receivers where message_id in (#{message_ids}) ").each{|row| receivers << row }
    output = FasterCSV.generate do |csv|
      line = ["id",  "user_id","admin_id","message_id","message_folder_id","replay_message_id", "open_time","rubbish","deleted", "created_at","updated_at","admin_rubbish","user_rubbish","admin_message_folder_id","real_time" ]
      csv << line
      receivers.each do |receiver|
        line = receiver
        csv << line
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/receivers.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
  end

  # 将当前加盟校下的schedules csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130716
  def self.out_put_schedules(id, server_name, project_name, mysql)
    schedules = []
    schedule_ids = []
    # sql 语句
    mysql.query("SELECT * FROM schedules").each{|row| schedules << row }
    output = FasterCSV.generate do |csv|
      line = ["id","from_at","to_at","name","memo","deleted", "created_at","updated_at"]
      csv << line
      schedules.each do |schedule|
        line = schedule
        csv << line
        schedule_ids << schedule[0]
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/schedules.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
    return schedule_ids.join(",")
  end

  # 将当前加盟校下的schedule_courses csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130716
  def self.out_put_schedule_courses(schedule_ids,course_ids,id, server_name, project_name, mysql)
    schedule_courses = []
    schedule_course_ids = []
    # sql 语句
    mysql.query("SELECT * FROM schedule_courses where schedule_id in (#{schedule_ids}) and course_id in (#{course_ids})").each{|row| schedule_courses << row }
    output = FasterCSV.generate do |csv|
      line = ["id","course_id","schedule_id","deleted", "created_at","updated_at"]
      csv << line
      schedule_courses.each do |schedule_course|
        line = schedule_course
        csv << line
        schedule_course_ids << schedule_course[0]
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/schedule_courses.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
    return schedule_course_ids.join(",")
  end

  # 将当前加盟校下的schedule_user_hopes csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130716
  def self.out_put_schedule_user_hopes(schedule_course_ids,schedule_ids,user_ids,id, server_name, project_name, mysql)
    schedule_user_hopes = []
    # sql 语句
    mysql.query("SELECT * FROM schedule_user_hopes where schedule_course_id in (#{schedule_course_ids}) or user_id in (#{user_ids}) and schedule_id in (#{schedule_ids})").each{|row| schedule_user_hopes << row }
    output = FasterCSV.generate do |csv|
      line = ["id",  "schedule_id","user_id","message_id","schedule_course_id","attend_status","deleted", "created_at","updated_at","force_cancel" ]
      csv << line
      schedule_user_hopes.each do |schedule_user_hope|
        line = schedule_user_hope
        csv << line
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/schedule_user_hopes.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
  end

  # 将当前加盟校下的taggings csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw 20130716
  def self.out_put_taggings(user_ids,library_ids,content_ids,enquete_ids,course_ids, id, server_name, project_name, mysql)
    taggings = []
    tagging_ids = []
    # sql 语句
    mysql.query("SELECT * FROM taggings ").each{|row| taggings << row }
    content_ids = content_ids.split(",") if content_ids.present?
    library_ids = library_ids.split(",") if library_ids.present?
    user_ids = user_ids.split(",") if user_ids.present?
    course_ids = course_ids.split(",") if course_ids.present?
    enquete_ids = enquete_ids.split(",") if enquete_ids.present?
    output = FasterCSV.generate do |csv|
      line = ["id",  "tag_id",  "taggable_id",  "tagger_id", "tagger_type", "taggable_type","context","created_at" ]
      csv << line
      taggings.each do |tagging|
        obj_id = tagging[2]
        if tagging[5] == "Content" && content_ids.include?(obj_id)
          line = tagging
          csv << line
          tagging_ids << tagging[1]
        elsif tagging[5] == "Library" && library_ids.include?(obj_id)
          line = tagging
          csv << line
          tagging_ids << tagging[1]
        elsif tagging[5] == "User" && user_ids.include?(obj_id)
          line = tagging
          csv << line
          tagging_ids << tagging[1]
        elsif tagging[5] == "Course" && course_ids.include?(obj_id)
          line = tagging
          csv << line
          tagging_ids << tagging[1]
        elsif tagging[5] == "Enquete" && enquete_ids.include?(obj_id)
          line = tagging
          csv << line
          tagging_ids << tagging[1]
        end
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/taggings.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
    return tagging_ids.join(",")
  end

  # 将当前加盟校下的attachments csv文件导出
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw 20130716 
  def self.out_put_attachments(message_ids, id, server_name, project_name, mysql)
    attachments = []
   
    # sql 语句
    mysql.query("SELECT * FROM attachments where owner_id in (#{message_ids}) ").each{|row| attachments << row }
    output = FasterCSV.generate do |csv|
      line = ["id","type", "owner_id", "file_path", "file_name", "deleted", "created_at",  "updated_at" ]
      csv << line
      attachments.each do |attachment|
        line = attachment
        csv << line
      end
    end
    #转码
    #文件的路径
    file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}/attachments.csv"
    file = File.new(file_path, "ab")
    File.open(file_path, "wb") do |f|
      #文件写入内容
      f.write output
    end
    
  end

end
