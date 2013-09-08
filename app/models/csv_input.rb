class CsvInput < ActiveRecord::Base
  acts_as_paranoid
  TOGO_DB_SELECT = [["local", "192.168.75.221", "root", "123456", "sc-trunk"],
#TOGO_DB_SELECT = [["local", "localhost", "root", "123456", "sc-trunk1"],
    ["togo-dev", "219.94.238.194", "togo_user", "tk9ay5OH", "togo_devs"],
    ["togo-test", "219.94.238.194", "togo_user", "tk9ay5OH", "togo_test"],
    ["global-g8", " 192.168.75.221", "root", "123456", "sc-trunk"]
  ]

  TOGO_SELECT = [["開発環境", "dev"], ["検証環境", "staging"]]
  #受讲期间终了日，默认值
  LECTURE_END_DAY = "2013-12-31 00:00:00"

  #文字列の改行コードを<br />に変換
  def self.to_br(str)
    unless str.blank?
      return str.gsub(/\n|\r\n|\r/, '<br />')
    else
      return ""
    end
  end

  # 选择要导入的服务器
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zq 20130711
  def self.db_select(server_name)
    case server_name
    when "dev"
      return TOGO_DB_SELECT[1][1],TOGO_DB_SELECT[1][2],TOGO_DB_SELECT[1][3],TOGO_DB_SELECT[1][4]
    when "staging"
      return TOGO_DB_SELECT[2][1],TOGO_DB_SELECT[2][2],TOGO_DB_SELECT[2][3],TOGO_DB_SELECT[2][4]
    when "benfan"
      return TOGO_DB_SELECT[3][1],TOGO_DB_SELECT[3][2],TOGO_DB_SELECT[3][3],TOGO_DB_SELECT[3][4]
    else
      return TOGO_DB_SELECT[0][1],TOGO_DB_SELECT[0][2],TOGO_DB_SELECT[0][3],TOGO_DB_SELECT[0][4]
    end
  end
  # 将下载的csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zq 20130711
  def self.input(id, server_name="local", project_name="schoolcity", import_server_name="local", sort="1")
    #define log
    jp_log =  Logger.new(STDOUT)
    input_log = Logger.new("#{RAILS_ROOT}/log/input_#{import_server_name}_#{id}_#{Time.now.strftime("%Y%m%d")}.txt")
    input_log.formatter = Logger::Formatter.new
    input_log.datetime_format = "%Y-%m-%d %H:%M:%S"
    mysql = Mysql.init()
    #选择数据库
    db_server,user_name,user_pass,db_name = db_select(import_server_name)
    input_log.info "================db server info ================="
    input_log.info "===input_ip:#{db_server},===input_user_name:#{user_name},=====input_user_pass:#{user_pass},===input_db:#{db_name}, ====sort:#{sort} ================="
    #连接数据库
    mysql.connect(db_server,user_name,user_pass,db_name)
    #设置编码方式
    mysql.query("SET NAMES UTF8 ")
    #创建文件夹
    csv_file_path = RAILS_ROOT + "/public/#{project_name}/#{server_name}/#{id}"

    #write log
    input_log.info "================input start ================="
    input_log.info "===========school_id: #{id},server_name:#{server_name}============"

    school_id, teacher_ids = input_admins(id, mysql, csv_file_path,input_log)

    jp_log.info '========================'
    jp_log.info 'WIL IMPORT NOW'	


    import_part_1(id, mysql, csv_file_path,input_log, school_id) #if sort.to_s == "1" || sort.to_s == "4" || sort.to_s == "5"

    import_part_2(id, mysql, csv_file_path,input_log, school_id) #if sort.to_s == "2" || sort.to_s == "4" || sort.to_s == "5"
    
    puts '================'
    puts 'import finish'


    #import_part_3(id, mysql, csv_file_path,input_log, school_id) if sort.to_s == "3" || sort.to_s == "5"

    input_log.info "==========import over============="

    #导入时间
    @output = CsvOutput.find(:first, :conditions =>
        ["school_id = ? and project_name = ? and server_name = ? and input_server_name = ? and sort = ?",
        id, project_name, server_name, import_server_name, sort])
    begin
	puts '============='
	puts 'OK'
	puts @output
    	@output.input_time = Time.now()
    	@output.save!
    rescue
	puts '==================='
	puts id
	puts project_name
	puts server_name
	puts import_server_name
	puts sort
    end     
  end

  # part1
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zq 20130711
  def self.import_part_1(id, mysql, csv_file_path,input_log, school_id=nil)
    input_log.info "========Priority  1 start========"
    input_log.info "====admins input start============"

    #users csv 导入
    input_log.info "====users input start============"
    input_users(school_id, mysql, csv_file_path,input_log)

    #courses csv 导入 分为course和course_details
    input_log.info "====courses input start============"
    input_courses( mysql, csv_file_path,input_log)

    #subjects csv 导入
    input_log.info "====subjects input start============"
    input_subjects( mysql, csv_file_path,input_log)

    #content csv导入
    input_log.info "====contents input start============"
    input_contents( mysql, csv_file_path,input_log)

    #subject_contents csv导入
    input_log.info "====subject_contents input start============"
    input_subject_contents( mysql, csv_file_path,input_log)

    #course_categories csv导入
    input_log.info "====course_categories input start============"
    input_course_categories( mysql, csv_file_path,input_log)

    #library csv导入
    input_log.info "====libraries input start============"
    input_libraries(mysql, csv_file_path,input_log)

    #free_pages csv导入
    input_log.info "====free_pages input start============"
    input_free_pages(mysql, csv_file_path,input_log)

    #course_teachers csv导入
    input_log.info "====course_teachers input start============"
    input_course_teachers(mysql, csv_file_path ,school_id,input_log)

    #exams csv导入
    input_log.info "====exams input start============"
    input_exams(mysql, csv_file_path,input_log)

    #exam_titles csv导入
    input_log.info "====exam_titles input start============"
    input_exam_titles(mysql, csv_file_path,input_log)

    #exam_questions csv导入
    input_log.info "====exam_questions input start============"
    input_exam_questions(mysql, csv_file_path,input_log)

    #exam_question_choices csv导入
    input_log.info "====exam_question_choices input start============"
    input_exam_question_choices(mysql, csv_file_path,input_log)

    #purchases csv 导入 分为purchases和purchase_infos
    input_log.info "====purchases input start============"
    input_purchases(mysql, csv_file_path, school_id,input_log)

    #enquete.csv导入
    input_log.info "====enquetes input start============"
    input_enquetes(mysql, csv_file_path,input_log)

    #enquete_users.csv导入
    input_log.info "====enquete_users input start============"
    input_enquete_users(mysql, csv_file_path,input_log)

    #enquete_users.csv导入
    input_log.info "====enquete_courses input start============"
    input_enquete_courses(mysql, csv_file_path,input_log)

    #enquete_questions.csv导入
    input_log.info "====enquete_questions input start============"
    input_enquete_questions(mysql, csv_file_path,input_log)

    #enquete_question_choices.csv导入
    input_log.info "====enquete_question_choices input start============"
    input_enquete_question_choices(mysql, csv_file_path,input_log)

    #homeworks csv导入
    input_log.info "=====homeworks input start============"
    input_homeworks(mysql, csv_file_path,input_log)

    #contact_courses csv导入
    input_log.info "===========contact_courses input start============"
    input_contact_courses(mysql, csv_file_path,input_log)

    #purchase_logs csv导入
    input_log.info "===========purchase_logs input start============"
    input_purchase_logs(mysql, csv_file_path, school_id,input_log)

    #purchase_confirm_logs csv导入
    input_log.info "===========purchase_confirm_logs input start============"
    input_purchase_confirm_logs(mysql, csv_file_path, school_id,input_log)

    #school_users csv 导入
    input_log.info "===========school_users input start============"
    input_school_users(school_id, mysql, csv_file_path,input_log)

    #comments csv导入
    input_log.info "===========comments input start============"
    input_comments(school_id, mysql, csv_file_path,input_log)

    #user_sns csv导入
    input_log.info "===========user_sns input start============"
    input_user_sns( mysql, csv_file_path,input_log)

    #mess_groups csv导入
    input_log.info "===========mess_groups input start============"
    input_mess_groups(mysql, csv_file_path, school_id,input_log)

    #user_groups csv导入
    input_log.info "===========user_groups input start============"
    input_user_groups(mysql, csv_file_path,input_log)

    #tags csv导入
    input_log.info "===========tags input start============"
    input_tags(mysql, csv_file_path,input_log)

    #taggings csv导入
    input_log.info "===========taggings input start============"
    input_taggings(mysql, csv_file_path,input_log)

    input_log.info "==========Priority  1 end============="
  end

  def self.import_part_2(id, mysql, csv_file_path,input_log, school_id=nil)
    input_log.info "==========Priority  2 start============="
    #inquiries csv导入
    input_log.info "===========inquiries input start============"
    input_inquiries(mysql, csv_file_path,input_log, school_id)

    #infos csv导入
    input_log.info "===========infos input start============"
    input_infos(mysql, csv_file_path,input_log)

    #course_infos csv导入
    input_log.info "===========course_infos input start============"
    input_course_infos(mysql, csv_file_path,input_log)

    #exam_result_totals csv导入
    input_log.info "===========exam_result_totals input start============"
    input_exam_result_totals(mysql, csv_file_path,input_log)

    #exam_results csv导入
    input_log.info "===========exam_results input start============"
    input_exam_results(mysql, csv_file_path,input_log)

    #exam_result_details csv导入
    input_log.info "===========exam_result_details input start============"
    input_exam_result_details(mysql, csv_file_path,input_log)

    #course_email_temps csv导入
    input_log.info "===========course_email_temps input start============"
    input_course_email_temps(mysql, csv_file_path,input_log)

    #email_templates csv导入
    input_log.info "===========email_templates input start============"
    input_email_templates(mysql, csv_file_path, school_id,input_log)


    #message_folders csv导入
    input_log.info "===========message_folders input start============"
    input_message_folders(mysql, csv_file_path,input_log)

    #messages csv导入
    input_log.info "===========messages input start============"
    input_messages(mysql, csv_file_path,input_log)

    #attachments csv导入
    input_log.info "===========attachments input start============"
    input_attachments(mysql, csv_file_path,input_log)

    #subject_study_logs csv导入
    input_log.info "===========subject_study_logs input start============"
    input_subject_study_logs(mysql, csv_file_path,input_log)

    #enquete_results 导入
    input_log.info "===========enquete_results input start============"
    input_enquete_results(mysql, csv_file_path,input_log)

    #enquete_result_details 导入
    input_log.info "===========enquete_result_details input start============"
    input_enquete_result_details(mysql, csv_file_path,input_log)

    #file_shares csv导入
    input_log.info "===========file_shares input start============"
    input_file_shares(mysql, csv_file_path,input_log)

    #file_share_replies csv导入
    input_log.info "===========file_share_replies input start============"
    input_file_share_replies(mysql, csv_file_path,input_log)

    #user_login_logs csv导入
    input_log.info "===========user_login_logs input start============"
    input_user_login_logs(mysql, csv_file_path,input_log)

    #receivers csv导入
    input_log.info "===========receivers input start============"
    input_receivers(mysql, csv_file_path,input_log)

    input_log.info "==========Priority  2 end============="
  end
  
  def self.import_part_3(id, mysql, csv_file_path,input_log, school_id=nil)
    input_log.info "==========Priority  3 start============="
    #lives csv导入
    input_log.info "===========lives input start============"
    input_lives(mysql, csv_file_path, school_id,input_log)

    #record_servers csv导入
    input_log.info "===========record_servers input start============"
    input_record_servers(mysql, csv_file_path,input_log)

    #force_converts csv导入
    input_log.info "===========force_converts input start============"
    input_force_converts(mysql, csv_file_path,input_log)

    #course_lives csv导入
    input_log.info "===========course_lives input start============"
    input_course_lives(mysql, csv_file_path,input_log)

    #live_urls csv导入
    input_log.info "===========live_urls input start============"
    input_live_urls(mysql, csv_file_path,input_log)

    #iframe_urls csv导入
    input_log.info "===========iframe_urls input start============"
    input_iframe_urls(mysql, csv_file_path,input_log)

    #live_users csv导入
    input_log.info "===========live_users input start============"
    input_live_users(mysql, csv_file_path,input_log)

    #view_members csv导入
    input_log.info "===========view_members input start============"
    input_view_members(mysql, csv_file_path,input_log)

    #archives csv导入
    input_log.info "===========archives input start============"
    input_archives(mysql, csv_file_path,input_log)

    #live_user_hopes csv导入
    input_log.info "===========live_user_hopes input start============"
    input_live_user_hopes(mysql, csv_file_path,input_log)

    #tv_action_logs csv导入
    input_log.info "===========tv_action_logs input start============"
    input_tv_action_logs(mysql, csv_file_path,input_log)

    #tv_chat_logs csv导入
    input_log.info "===========tv_chat_logs input start============"
    input_tv_chat_logs(mysql, csv_file_path,input_log)

    #tv_file_sends csv导入
    input_log.info "===========tv_file_sends input start============"
    input_tv_file_sends(mysql, csv_file_path,input_log)

    #tv_action_logs csv导入
    input_log.info "===========tv_layouts input start============"
    input_tv_layouts(mysql, csv_file_path,input_log)


    #tv_status csv导入
    input_log.info "===========tv_status input start============"
    input_tv_status(mysql, csv_file_path,input_log)

    #tv_streams csv导入    /
    input_log.info "===========tv_streams input start============"
    input_tv_streams(mysql, csv_file_path,input_log)

    #tv_enquetes csv导入
    input_log.info "===========tv_enquetes input start============"
    input_tv_enquetes(mysql, csv_file_path,input_log)

    #tv_questions csv导入
    input_log.info "===========tv_questions input start============"
    input_tv_questions(mysql, csv_file_path,input_log)

    #tv_enquete_results csv导入
    input_log.info "===========tv_enquete_results input start============"
    input_tv_enquete_results(mysql, csv_file_path,input_log)

    #schedules csv导入
    input_log.info "===========schedules input start============"
    input_schedules(mysql, csv_file_path,input_log)

    #schedule_courses csv导入
    input_log.info "===========schedule_courses input start============"
    input_schedule_courses(mysql, csv_file_path,input_log)

    #schedule_user_hopes csv导入
    input_log.info "===========schedule_user_hopes input start============"
    input_schedule_user_hopes(mysql, csv_file_path,input_log)

    #favorites csv导入
    input_log.info "===========favorites input start============"
    input_favorites(mysql, csv_file_path,input_log)

    #ckeditor_assets csv导入
    input_log.info "===========ckeditor_assets input start============"
    input_ckeditor_assets(mysql, csv_file_path,input_log)

    input_log.info "==========Priority  3 end============="
  end
	
  # 将下载的admins.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zq20130711
  def self.input_admins(id, mysql, csv_file_path,input_log)
    #find file
    old_file = csv_file_path + "/admins.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO admins"
    sql << "(sc_old_id, type, company_code, tel, fax, zip_code, address1, address2,
deleted, name, name2, login, email,crypted_password, salt, created_at, updated_at, remember_token,
remember_token_expires_at, photo_path, create_by_id, photo, receiver_flag, out_content_flag, login_code, last_live_type, `mod`)"
    sql << " VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)

    row_index = 0
    #导入加盟校
    FasterCSV.foreach(old_file) do |row|
      #第一行不导入
      row_index += 1
      #如果这个加盟校已经导入了，就不要再导入了
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      if row[0].to_s == id.to_s && row[1].to_s == "School"
        school_id = []
        mysql.query("SELECT id FROM admins where sc_old_id = (#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each{|r|  school_id << r }
        school_id = school_id.to_s
        #如果这个加盟校已经导入了，就跳出
        break if school_id.present?
        #execute
        st.execute(
          row[0].to_s.present? ? row[0].to_s : nil, #sc_old_id
          row[1].to_s.present? ? row[1].to_s : nil, #type
          row[2].to_s.present? ? row[2].to_s : nil, #company_code
          row[3].to_s.present? ? row[3].to_s : nil, #tel
          row[4].to_s.present? ? row[4].to_s : nil, #fax
          row[5].to_s.present? ? row[5].to_s : nil, #zip_code
          row[6].to_s.present? ? row[6].to_s : nil, #address1
          row[7].to_s.present? ? row[7].to_s : nil, #address2
          row[8].to_s.present? ? row[8].to_s : nil, #deleted
          row[9].to_s.present? ? row[9].to_s : nil, #name
          row[10].to_s.present? ? row[10].to_s : nil,#name2
          row[11].to_s.present? ? row[11].to_s : nil,#login
          row[12].to_s.present? ? row[12].to_s : nil,#email
          row[13].to_s.present? ? row[13].to_s : nil,#crypted_password
          row[14].to_s.present? ? row[14].to_s : nil,#salt
          row[15].to_s.present? ? row[15].to_s : nil,#created_at
          row[16].to_s.present? ? row[16].to_s : nil,#updated_at
          row[17].to_s.present? ? row[17].to_s : nil,#remember_token
          row[18].to_s.present? ? row[18].to_s : nil,#remember_token_expires_at
          row[19].to_s.present? ? row[19].to_s : nil,#photo_path
          #现行sc只有一个admin，id是3，所有的加盟校都是这个admin建的
          3,                                          #create_by_id
          row[21].to_s.present? ? row[21].to_s : nil, #photo
          row[22].to_s.present? ? row[22].to_s : nil, #receiver_flag
          row[23].to_s.present? ? row[23].to_s : nil, #out_content_flag
          row[2].to_s.present? ? row[2].to_s : nil,   #login_code  默认跟company_code一样
          row[25].to_s.present? ? row[25].to_s : nil,   #last_live_type
          "ja" #mod默认设定为ja
        )
        break
      end
    end

    #导入讲师
    new_id = []
    #找出加盟校的新id
    mysql.query("SELECT id FROM admins where sc_old_id = (#{id}) ORDER BY id DESC LIMIT 1").each{|r|  new_id << r }
    new_id = new_id.to_s
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      
      #第一行不导入
      row_index += 1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #如果这个讲师已经导入，就进行下一次循环
      teacher_id = []
      mysql.query("SELECT id FROM admins where sc_old_id = (#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each{|r|  teacher_id << r }
      teacher_id = teacher_id.to_s
      next if teacher_id.present?
      if row[0].to_s.strip != id.to_s
        #execute
        st.execute(
          row[0].to_s.present? ? row[0].to_s : nil, #sc_old_id
          row[1].to_s.present? ? row[1].to_s : nil, #type
          row[2].to_s.present? ? row[2].to_s : nil, #company_code
          row[3].to_s.present? ? row[3].to_s : nil, #tel
          row[4].to_s.present? ? row[4].to_s : nil, #fax
          row[5].to_s.present? ? row[5].to_s : nil, #zip_code
          row[6].to_s.present? ? row[6].to_s : nil, #address1
          row[7].to_s.present? ? row[7].to_s : nil, #address2
          row[8].to_s.present? ? row[8].to_s : nil, #deleted
          row[9].to_s.present? ? row[9].to_s : nil, #name
          row[10].to_s.present? ? row[10].to_s : nil,#name2
          row[11].to_s.present? ? row[11].to_s : nil,#login
          row[12].to_s.present? ? row[12].to_s : nil,#email
          row[13].to_s.present? ? row[13].to_s : nil,#crypted_password
          row[14].to_s.present? ? row[14].to_s : nil,#salt
          row[15].to_s.present? ? row[15].to_s : nil,#created_at
          row[16].to_s.present? ? row[16].to_s : nil,#updated_at
          row[17].to_s.present? ? row[17].to_s : nil,#remember_token
          row[18].to_s.present? ? row[18].to_s : nil,#remember_token_expires_at
          row[19].to_s.present? ? row[19].to_s : nil,#photo_path
          #讲师都是本加盟校建的
          new_id,
          row[21].to_s.present? ? row[21].to_s : nil, #photo
          row[22].to_s.present? ? row[22].to_s : nil, #receiver_flag
          row[23].to_s.present? ? row[23].to_s : nil, #out_content_flag
          nil,                                        #讲师的login_code是NULL
          0,                                         #last_live_type
          nil                                         #mod
        )
      end
    end
    #找出这个加盟校下的所有讲师
    teacher_ids = []
    mysql.query("SELECT id FROM admins where create_by_id = (#{new_id}) and type = 'TeacherAdmin'").each{|r|  teacher_ids << r }
    teacher_ids = teacher_ids.flatten.join(",")
    #返回加盟校的新id和这个加盟校的所有讲师的id
    return new_id, teacher_ids
  end

  # 将下载的courses.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw20130717
  def self.input_courses( mysql, csv_file_path,input_log)
    #find file
    old_file = csv_file_path + "/courses.csv"
    #prepare
    return unless File.exist?(old_file)
   
    sql = "INSERT INTO courses"
    sql << "(sc_old_id, course_id, create_id, name, price, open_date, close_date, pay_type,
sort, pay_flag, single_flag, icon_string, force_flag,backgroud_flag, deleted, user_signup_items, flag,regist_displayed,
school_id, record_flag, layout_type,created_at,updated_at, logo, lecture_start, lecture_end,comment_flag,lecture_days,schedule_force_flag,inquiry_flag,
material_flag,file_share_flag,schedule_order_flag,message_after_flag,show_name_flag,course_time,period,course_code)"
    sql << " VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
   
    row_index = 0
    #导入courses
    FasterCSV.foreach(old_file) do |row|
  
      #第一行不导入
      row_index += 1
      input_log.info "===========#{row_index}============"
      #如果这个courses已经导入了，就不要再导入了
      next if row_index == 1
      #查找到相应的created_id
      c_id = []
      mysql.query("SELECT id FROM admins where sc_old_id = (#{row[2].to_s}) ORDER BY id DESC LIMIT 1").each{|r|  c_id << r }
      #查找到相应的school_id
      s_id = []
      mysql.query("SELECT id FROM admins where sc_old_id = (#{row[22].to_s}) ORDER BY id DESC LIMIT 1").each{|r|  s_id << r }
      course_code = row_index.to_s + s_id.to_s
      #导入有料的course

      if row[10].to_s == "0"
        course_id =[]
        mysql.query("SELECT id FROM courses where sc_old_id = (#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each{|r|  course_id << r }
        course_id = course_id.to_s
        #如果这个course没有导入就开始导入
        if course_id.blank?
          #execute
          st.execute(
            row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
            row[1].to_s.present? ? row[1].to_s : nil,#course_id
            c_id.to_s.present? ? c_id.to_s : nil,#create_id
            row[3].to_s.present? ? row[3].to_s : nil,#name
            row[4].to_s.present? ? row[4].to_s : nil,#price
            row[6].to_s.present? ? row[6].to_s : nil,#open_date
            row[7].to_s.present? ? row[7].to_s : nil,#close_date
            row[8].to_s.present? ? row[8].to_s : nil,#pay_type
            row[9].to_s.present? ? row[9].to_s : nil,#sort
            row[10].to_s.present? ? row[10].to_s : nil,#pay_flag
            row[11].to_s.present? ? row[11].to_s : nil,#single_flag
            row[12].to_s.present? ? row[12].to_s : nil,#icon_string
            row[14].to_s.present? ? row[14].to_s : nil,#force_flag
            row[15].to_s.present? ? row[15].to_s : nil,#backgroud_flag
            row[16].to_s.present? ? row[16].to_s : nil,#deleted
            row[17].to_s.present? ? row[17].to_s : nil,#user_signup_items
            row[18].to_s.present? ? row[18].to_s : nil,#flag
            row[19].to_s.present? ? row[19].to_s : nil,#regist_displayed
            s_id.to_s.present? ? s_id.to_s : nil,#school_id
            row[23].to_s.present? ? row[23].to_s : nil,#record_flag
            row[24].to_s.present? ? row[24].to_s : nil,#layout_type
            row[25].to_s.present? ? row[25].to_s : nil,#created_at
            row[26].to_s.present? ? row[26].to_s : nil,#updated_at
            row[27].to_s.present? ? row[27].to_s : nil,#logo
            row[29].to_s.present? ? row[29].to_s : nil,#lecture_start
            row[30].to_s.present? ? row[30].to_s : nil,#lecture_end
            row[31].to_s.present? ? row[31].to_s : nil,#comment_flag
            row[32].to_s.present? ? row[32].to_s : nil,#lecture_days
            row[33].to_s.present? ? row[33].to_s : nil,#schedule_force_flag
            row[34].to_s.present? ? row[34].to_s : nil,#inquiry_flag
            row[35].to_s.present? ? row[35].to_s : nil,#material_flag
            row[36].to_s.present? ? row[36].to_s : nil,#file_share_flag
            row[37].to_s.present? ? row[37].to_s : nil,#schedule_order_flag
            row[38].to_s.present? ? row[38].to_s : nil,#message_after_flag
            row[39].to_s.present? ? row[39].to_s : nil,#show_name_flag
            120,#course_time
            nil,#period
            course_code
          )
        end
       
      else
        #判断是否导入
        course_id =[]
        mysql.query("SELECT id FROM courses where sc_old_id = (#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each{|r|  course_id << r }
        course_id = course_id.to_s
        if course_id.blank?
          free_id = []
          #判断无料course的course_id是否存在、不存在会抛异常、故做此判断
          if row[1].to_s.present?
            mysql.query("SELECT id FROM courses where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|r| free_id << r}
            free_id = free_id.to_s
          end
          st.execute(
            row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
            free_id.present? ? free_id : nil,#course_id
            c_id.to_s.present? ? c_id.to_s : nil,#create_id
            row[3].to_s.present? ? row[3].to_s : nil,#name
            row[4].to_s.present? ? row[4].to_s : nil,#price
            row[6].to_s.present? ? row[6].to_s : nil,#open_date
            row[7].to_s.present? ? row[7].to_s : nil,#close_date
            row[8].to_s.present? ? row[8].to_s : nil,#pay_type
            row[9].to_s.present? ? row[9].to_s : nil,#sort
            row[10].to_s.present? ? row[10].to_s : nil,#pay_flag
            row[11].to_s.present? ? row[11].to_s : nil,#single_flag
            row[12].to_s.present? ? row[12].to_s : nil,#icon_string
            row[14].to_s.present? ? row[14].to_s : nil,#force_flag
            row[15].to_s.present? ? row[15].to_s : nil,#backgroud_flag
            row[16].to_s.present? ? row[16].to_s : nil,#deleted
            row[17].to_s.present? ? row[17].to_s : nil,#user_signup_items
            row[18].to_s.present? ? row[18].to_s : nil,#flag
            row[19].to_s.present? ? row[19].to_s : nil,#regist_displayed
            s_id.present? ? s_id.to_s : nil,#school_id
            row[23].to_s.present? ? row[23].to_s : nil,#record_flag
            row[24].to_s.present? ? row[24].to_s : nil,#layout_type
            row[25].to_s.present? ? row[25].to_s : nil,#created_at
            row[26].to_s.present? ? row[26].to_s : nil,#updated_at
            row[27].to_s.present? ? row[27].to_s : nil,#logo
            row[29].to_s.present? ? row[29].to_s : nil,#lecture_start
            row[30].to_s.present? ? row[30].to_s : nil,#lecture_end
            row[31].to_s.present? ? row[31].to_s : nil,#comment_flag
            row[32].to_s.present? ? row[32].to_s : nil,#lecture_days
            row[33].to_s.present? ? row[33].to_s : nil,#schedule_force_flag
            row[34].to_s.present? ? row[34].to_s : nil,#inquiry_flag
            row[35].to_s.present? ? row[35].to_s : nil,#material_flag
            row[36].to_s.present? ? row[36].to_s : nil,#file_share_flag
            row[37].to_s.present? ? row[37].to_s : nil,#schedule_order_flag
            row[38].to_s.present? ? row[38].to_s : nil,#message_after_flag
            row[39].to_s.present? ? row[39].to_s : nil,#show_name_flag
            120,
            48,
            course_code
          )
        end

       
      end
      course_details(mysql,row)
    end
  
  end

  # 将下载的course_details导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw20130717
  def self.course_details(mysql, row)
    sql2 = "INSERT INTO course_details"
    sql2 << "(course_id,description,memo,start_live_message,head_link_tag,reservation_message,deleted,created_at,updated_at)"
    sql2 << "VALUES(?,?,?,?,?,?,?,?,?)"
    st2 = mysql.prepare(sql2)
    #开始导入course对应的course_detail
    ids = []
    mysql.query("SELECT id FROM courses where sc_old_id = (#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each{|r|  ids << r }
    #找到相应的course_id
    ids = ids.to_s
    #找到是否已经导入的数据、如果导入了就不再导入
    course_ids=[]
    mysql.query("SELECT id FROM course_details where course_id = #{ids} ORDER BY id DESC LIMIT 1").each{|w| course_ids << w }
    course_ids = course_ids.to_s
    if course_ids.blank?
      st2.execute(
        ids,#course_id
        row[5].to_s.present? ? row[5].to_s : nil,#description
        row[13].to_s.present? ? row[13].to_s : nil,#memo
        row[20].to_s.present? ? row[20].to_s : nil,#start_live_message
        row[28].to_s.present? ? row[28].to_s : nil,#head_link_tag
        row[21].to_s.present? ? row[21].to_s : nil,#reservation_message
        row[16].to_s.present? ? row[16].to_s : nil,#deleted
        row[25].to_s.present? ? row[25].to_s : nil,#created_at
        row[26].to_s.present? ? row[26].to_s : nil#updated_at
      )
    end
  end

  # 将下载的users.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by wxx20130717
  def self.input_users(id, mysql, csv_file_path,input_log)
    #find file
    old_file = csv_file_path + "/users.csv"
    return unless File.exist?(old_file)
    #users
    sql = "INSERT INTO users"
    sql << "(sc_old_id, create_id, first_login, login, first_name, last_name, first_name_py, last_name_py, email, crypted_password, salt, remember_token,
remember_token_expires_at, uuid_random, nickname, receiver_flag, deleted, created_at, updated_at, last_view_course_id)"
    sql << " VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)

    row_index = 0
    #导入user
    FasterCSV.foreach(old_file) do |row|
      #第一行不导入
      row_index += 1
      
      #如果这个user已经导入了，就不要再导入了
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      user_id = []
      mysql.query("SELECT id FROM users where sc_old_id = (#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each{|r|  user_id << r }
      user_id = user_id.to_s
      #如果这个user已经导入了，就跳出
      next if user_id.present?
      #execute
      st.execute(
        row[0].to_s.present? ? row[0].to_s : nil, #id
        id.to_s,#create_id
        1,#first_login
        row[1].to_s.present? ? row[1].to_s : nil, #login
        row[36].to_s.present? ? row[36].to_s : nil, #first_name
        row[37].to_s.present? ? row[37].to_s : nil,#last_name
        row[38].to_s.present? ? row[38].to_s : nil,#first_name_py
        row[39].to_s.present? ? row[39].to_s : nil,#last_name_py
        row[22].to_s.present? ? row[22].to_s : nil,#email
        row[23].to_s.present? ? row[23].to_s : nil,#crypted_password
        row[24].to_s.present? ? row[24].to_s : nil,#salt
        row[27].to_s.present? ? row[27].to_s : nil,#remember_token
        row[28].to_s.present? ? row[28].to_s : nil,#remember_token_expires_at
        row[41].to_s.present? ? row[41].to_s : nil,#uuid_random
        row[42].to_s.present? ? row[42].to_s : nil,#nickname
        row[48].to_s.present? ? row[48].to_s : nil,#receiver_flag
        row[21].to_s.present? ? row[21].to_s : nil,#deleted
        row[25].to_s.present? ? row[25].to_s : nil,#created_at
        row[26].to_s.present? ? row[26].to_s : nil,#updated_at
        row[49].to_s.present? ? row[49].to_s : nil#last_view_course_id
      )
      #user_infos
      user_infos(mysql, row)
    end
  end

  # user_infos
  #【引数】
  #【返値】
  #【注意】
  #【著作】by wxx20130718
  def self.user_infos(mysql, row)
    info_sql = "INSERT INTO user_infos"
    info_sql << "(user_id, parent_first_login, grade, company, department, office, zip_code, address1, address2, portable_email, tel, tel_mobile, sex,
birthday, user_photo, self_pr, resignation, card_num, card_validate_date, card_status, memo, pay_way, convenient_name, convenient_pay_name, convenient_pay_name_py, convenient_phone,
other_question, parent_login, guardian, guardian_pwd, advance_attend_time, parent_name_py, profile, deleted, created_at, updated_at)"
    info_sql << " VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
    info_st = mysql.prepare(info_sql)
    new_user_id = []
    mysql.query("SELECT id FROM users where sc_old_id = (#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each{|u|  new_user_id << u }
    new_user_id = new_user_id.to_s
    user_info_id = []
    mysql.query("SELECT id FROM user_infos where user_id = (#{new_user_id}) ORDER BY id DESC LIMIT 1").each{|i|  user_info_id << i }
    user_info_id = user_info_id.to_s
    next if user_info_id.present?
    info_st.execute(
      new_user_id.present? ? new_user_id : nil, #user_id
      1,#parent_first_login
      row[2].to_s.present? ? row[2].to_s : nil, #grade
      row[3].to_s.present? ? row[3].to_s : nil, #company
      row[4].to_s.present? ? row[4].to_s : nil,#department
      row[5].to_s.present? ? row[5].to_s : nil,#office
      row[6].to_s.present? ? row[6].to_s : nil,#zip_code
      row[7].to_s.present? ? row[7].to_s : nil,#address1
      row[8].to_s.present? ? row[8].to_s : nil,#address2
      row[9].to_s.present? ? row[9].to_s : nil,#portable_email
      row[10].to_s.present? ? row[10].to_s : nil,#tel
      row[29].to_s.present? ? row[29].to_s : nil,#tel_mobile
      row[11].to_s.present? ? row[11].to_s : nil,#sex
      row[12].to_s.present? ? row[12].to_s : nil,#birthday
      row[13].to_s.present? ? row[13].to_s : nil,#user_photo
      row[14].to_s.present? ? row[14].to_s : nil,#self_pr
      row[16].to_s.present? ? row[16].to_s : nil,#resignation
      row[17].to_s.present? ? row[17].to_s : nil,#card_num
      row[18].to_s.present? ? row[18].to_s : nil,#card_validate_date
      row[19].to_s.present? ? row[19].to_s : nil,#card_status
      row[20].to_s.present? ? row[20].to_s : nil,#memo
      row[31].to_s.present? ? row[31].to_s : nil,#pay_way
      row[32].to_s.present? ? row[32].to_s : nil,#convenient_name
      row[33].to_s.present? ? row[33].to_s : nil,#convenient_pay_name
      row[34].to_s.present? ? row[34].to_s : nil,#convenient_pay_name_py
      row[35].to_s.present? ? row[35].to_s : nil,#convenient_phone
      row[40].to_s.present? ? row[40].to_s : nil,#other_question
      row[15].to_s.present? ? row[15].to_s : nil,#parent_login
      row[43].to_s.present? ? row[43].to_s : nil,#guardian
      row[44].to_s.present? ? row[44].to_s : nil,#guardian_pwd
      row[45].to_s.present? ? row[45].to_s : nil,#advance_attend_time
      row[46].to_s.present? ? row[46].to_s : nil,#parent_name_py
      row[47].to_s.present? ? row[47].to_s : nil,#profile
      row[21].to_s.present? ? row[21].to_s : nil,#deleted
      row[25].to_s.present? ? row[25].to_s : nil,#created_at
      row[26].to_s.present? ? row[26].to_s : nil#updated_at
    )
  end


  # 将下载的purchase.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zq20130718
  def self.input_purchases(mysql, csv_file_path, school_id,input_log)
    #find file
    old_file = csv_file_path + "/purchase.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO purchases"
    sql << "(sc_old_id, user_id, course_id, code, monthly_flag, from_date, to_date, ajust_from_date,
ajust_to_date, ajust_price, relieve_flag, deleted, created_at, updated_at, memo, school_id,
manual_pay_flag, create_by_admin, limit_date, agent_code
)"
    sql << " VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)

    row_index = 0
    #导入purchases
    FasterCSV.foreach(old_file) do |row|
     
      #第一行不导入
      row_index += 1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      new_id = []
      user_id = []
      course_id = []
      #row[1] user_id
      #row[2] course_id
      mysql.query("SELECT id FROM purchases where sc_old_id = (#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each{|r|  new_id << r }
      new_id = new_id.to_s
      #如果这条记录已经导入了，就不要再导入了
      if new_id.blank?
        mysql.query("SELECT id FROM users where sc_old_id = (#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each{|r|  user_id << r }
        #新的 user_id
        user_id = user_id.to_s
        mysql.query("SELECT id FROM courses where sc_old_id = (#{row[2].to_s}) ORDER BY id DESC LIMIT 1").each{|r|  course_id << r }
        #新的course_id
        course_id = course_id.to_s
        #execute
        st.execute(
          row[0].to_s.present? ? row[0].to_s : nil,   # old id
          user_id.present? ? user_id : nil,           # user_id
          course_id.present? ? course_id : nil,       # course_id
          row[3].to_s.present? ? row[3].to_s : nil,   # code
          row[4].to_s.present? ? row[4].to_s : nil,   # monthly_flag
          row[16].to_s.present? ? row[16].to_s : nil, # from_date
          row[17].to_s.present? ? row[17].to_s : nil, # to_date
          row[18].to_s.present? ? row[18].to_s : nil, # ajust_from_date
          row[19].to_s.present? ? row[19].to_s : nil, # ajust_to_date
          row[20].to_s.present? ? row[20].to_s : nil, # ajust_price
          row[21].to_s.present? ? row[21].to_s : nil, # relieve_flag
          row[22].to_s.present? ? row[22].to_s : nil, # deleted
          row[23].to_s.present? ? row[23].to_s : nil, # created_at
          row[24].to_s.present? ? row[24].to_s : nil, # updated_at
          row[25].to_s.present? ? row[25].to_s : nil, # memo
          school_id,                                  # school_id 新的school_id会传递过来
          row[27].to_s.present? ? row[27].to_s : nil, # manual_pay_flag
          row[28].to_s.present? ? row[28].to_s : nil, # create_by_admin
          row[29].to_s.present? ? row[29].to_s : nil, # limit_date 受讲终了日，给个默认值
          row[35].to_s.present? ? row[35].to_s : nil  # agent_code
        )
      end
      input_purchase_infos(mysql, row)
    end
  end

  # 将下载的purchases.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zq20130718
  def self.input_purchase_infos(mysql, row)
    sql2 = "INSERT INTO purchase_infos"
    sql2 << "(purchase_id, signup_item1, signup_item2, signup_item3, signup_item4, signup_item5,
course_name, price, course_description, course_open_date, course_close_date, course_pay_type,
course_sort, course_pay_flag, course_single_flag, course_icon_string, course_force_flag)"
    sql2 << "VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
    st2 = mysql.prepare(sql2)
    #开始导入course对应的course_detail
    purchase_id = []
    mysql.query("SELECT id FROM purchases where sc_old_id = (#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each{|r|  purchase_id << r }
    #找到相应的course_id
    purchase_id = purchase_id.to_s
    #找到是否已经导入的数据、如果导入了就不再导入
    new_id = []
    mysql.query("SELECT id FROM purchase_infos where purchase_id = #{purchase_id} ORDER BY id DESC LIMIT 1").each{|r| new_id << r }
    new_id = new_id.to_s
    if new_id.blank?
      st2.execute(
        purchase_id,                                 #purchase_id
        row[30].to_s.present? ? row[30].to_s : nil,  #signup_item1
        row[31].to_s.present? ? row[31].to_s : nil,  #signup_item2
        row[32].to_s.present? ? row[32].to_s : nil,  #signup_item3
        row[33].to_s.present? ? row[33].to_s : nil,  #signup_item4
        row[34].to_s.present? ? row[34].to_s : nil,  #signup_item5
        row[5].to_s.present? ? row[5].to_s : nil,    #course_name
        row[6].to_s.present? ? row[6].to_s : nil,    #price
        row[7].to_s.present? ? row[7].to_s : nil,    #course_description
        row[8].to_s.present? ? row[8].to_s : nil,    #course_open_date
        row[9].to_s.present? ? row[9].to_s : nil,    #course_close_date
        row[10].to_s.present? ? row[10].to_s : nil,  #course_pay_type
        row[11].to_s.present? ? row[11].to_s : nil,  #course_sort
        row[12].to_s.present? ? row[12].to_s : nil,  #course_pay_flag
        row[13].to_s.present? ? row[13].to_s : nil,  #course_single_flag
        row[14].to_s.present? ? row[14].to_s : nil,  #course_icon_string
        row[15].to_s.present? ? row[15].to_s : nil   #course_force_flag
      )
    end
  end


  # 将下载的.csv文件导入
  # 将下载的subjects.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw20130718
  def self.input_subjects( mysql, csv_file_path,input_log)
    #find file
    old_file = csv_file_path + "/subjects.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO subjects "
    sql << "(sc_old_id,course_id,name,sort,deleted,memo,created_at,updated_at)"
    sql << "VALUES(?,?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
    
      #第一行不导入
      row_index += 1
    
      #如果这个subjects已经导入了，就不要再导入了
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入、如果已经导入则不再导入
      s_id = []
      mysql.query("SELECT id FROM subjects where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|w| s_id << w}
      #查找到相应的course_id对应的course的新id
      s_id = s_id.to_s
      next if s_id.present?
      c_id = []
      mysql.query("SELECT id FROM courses where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|r| c_id << r}
      c_id = c_id.to_s
      st.execute(
        row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
        c_id.to_s.present? ? c_id.to_s : nil,#course_id
        row[2].to_s.present? ? row[2].to_s : nil,#name
        row[3].to_s.present? ? row[3].to_s : nil,#sort
        row[4].to_s.present? ? row[4].to_s : nil,#deleted
        row[5].to_s.present? ? row[5].to_s : nil,#memo
        row[6].to_s.present? ? row[6].to_s : nil,#created_at
        row[7].to_s.present? ? row[7].to_s : nil#updated_at
      )
    end
  end



  # 将下载的school_users.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by wxx20130718
  def self.input_school_users(school_id, mysql, csv_file_path,input_log)
    #find file
    old_file = csv_file_path + "/school_users.csv"
    return unless File.exist?(old_file)
    #school_users
    sql = "INSERT INTO school_users"
    sql << "(sc_old_id, user_id, school_id, deleted, created_at, updated_at)"
    sql << " VALUES(?,?,?,?,?,?)"
    st = mysql.prepare(sql)

    row_index = 0
    #导入school_users
    FasterCSV.foreach(old_file) do |row|
     
      #第一行不导入
      row_index += 1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      school_user_id = []
      mysql.query("SELECT id FROM school_users where sc_old_id = (#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each{|s|  school_user_id << s }
      school_user_id = school_user_id.to_s
      #如果school_user已经导入了，就跳出
      next if school_user_id.present?
      #找到新user_id
      new_user_id = []
      mysql.query("SELECT id FROM users where sc_old_id = (#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each{|u|  new_user_id << u }
      new_user_id = new_user_id.to_s
      #execute
      st.execute(
        row[0].to_s.present? ? row[0].to_s : nil, #sc_old_id
        new_user_id.present? ? new_user_id : nil,#user_id
        school_id,#school_id
        row[3].to_s.present? ? row[3].to_s : nil, #deleted
        row[4].to_s.present? ? row[4].to_s : nil, #created_at
        row[5].to_s.present? ? row[5].to_s : nil#updated_at
      )
    end
  end

  # 将下载的user_sns导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130718
  def self.input_user_sns( mysql, csv_file_path,input_log)
    #find file
    old_file = csv_file_path + "/user_sns.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO user_sns "
    sql << "(sc_old_id,user_id,deleted,created_at,updated_at,t_access_token,t_access_token_secret,f_access_token)"
    sql << "VALUES(?,?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
     
      #第一行不导入
      row_index += 1
     
      #如果这个user_sns已经导入了，就不要再导入了
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入、如果已经导入则不再导入
      user_sns_id = []
      mysql.query("SELECT id FROM user_sns where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|w| user_sns_id << w}
      user_sns_id = user_sns_id.to_s
      #查找到相应的user_id对应的user的新id
      user_id = []
      mysql.query("SELECT id FROM users where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|r| user_id << r}
      if user_sns_id.blank?
        st.execute(
          row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
          user_id.to_s.present? ? user_id.to_s : nil,#user_id
          row[2].to_s.present? ? row[2].to_s : nil,#deleted
          row[3].to_s.present? ? row[3].to_s : nil,#created_at
          row[4].to_s.present? ? row[4].to_s : nil,#updated_at
          row[5].to_s.present? ? row[5].to_s : nil,#t_access_token
          row[6].to_s.present? ? row[6].to_s : nil,#t_access_token_secret
          row[7].to_s.present? ? row[7].to_s : nil#f_access_token
        )
      end
    end
  end

  # 将下载的course_categories导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130718
  def self.input_course_categories( mysql, csv_file_path,input_log)
    #find file
    old_file = csv_file_path + "/course_categories.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO course_categories "
    sql << "(sc_old_id,course_id,category_id,deleted,created_at,updated_at)"
    sql << "VALUES(?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
    
      #第一行不导入
      row_index += 1
     
      #如果这个course_categories已经导入了，就不要再导入了
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入、如果已经导入则不再导入
      course_category_id = []
      mysql.query("SELECT id FROM course_categories where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|w| course_category_id << w}
      course_category_id = course_category_id.to_s
      #查找到相应的course_id对应的course的新id
      course_id = []
      mysql.query("SELECT id FROM courses where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|r| course_id << r}
      course_id = course_id.to_s
      if course_category_id.blank?
        st.execute(
          row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
          course_id.to_s.present? ? course_id.to_s : nil,#course_id
          row[2].to_s.present? ? row[2].to_s : nil,#category_id
          row[3].to_s.present? ? row[3].to_s : nil,#deleted
          row[4].to_s.present? ? row[4].to_s : nil,#created_at
          row[5].to_s.present? ? row[5].to_s : nil #updated_at
        )
      end
    end
  end
  # 将下载的contents.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw20130718
  def self.input_contents( mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/contents.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO contents "
    sql << "(sc_old_id,name,file_path,url,video,keyword,memo,deleted,sort,school_id,course_id,
              android_flag,android_path,foreign_flag,scorm_type,scorm_flag,out_content_flag,created_at,updated_at)"
    sql << "VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
    
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入
      content_id = []
      mysql.query("SELECT id FROM contents where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|w| content_id << w}
      content_id = content_id.to_s
      next if content_id.present?
      #查找到school_id
      if row[13].to_s.present?
        school_id = []
        mysql.query("SELECT id FROM admins where sc_old_id =(#{row[13].to_s}) ORDER BY id DESC LIMIT 1").each {|r| school_id << r}
      end
      #查找到相对的course_id
      if row[14].to_s.present?
        course_id = []
        mysql.query("SELECT id FROM courses where sc_old_id =(#{row[14].to_s}) ORDER BY id DESC LIMIT 1").each {|c| course_id << c}
      end
      
      st.execute(
        row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
        row[1].to_s.present? ? row[1].to_s : nil,#name
        row[2].to_s.present? ? row[2].to_s : nil,#file_path
        row[3].to_s.present? ? row[3].to_s : nil,#url
        row[4].to_s.present? ? row[4].to_s : nil,#video
        row[5].to_s.present? ? row[5].to_s : nil,#keyword
        row[6].to_s.present? ? row[6].to_s : nil,#memo
        row[7].to_s.present? ? row[7].to_s : nil,#deleted
        row[8].to_s.present? ? row[8].to_s : nil,#sort
        school_id.to_s.present? ? school_id.to_s : nil,#school_id
        course_id.to_s.present? ? course_id.to_s : nil,#course_id
        row[18].to_s.present? ? row[18].to_s : nil,#android_flag
        row[19].to_s.present? ? row[19].to_s : nil,#android_path
        row[20].to_s.present? ? row[20].to_s : nil,#foreign_flag
        row[21].to_s.present? ? row[21].to_s : nil,#scorm_type
        row[22].to_s.present? ? row[22].to_s : nil,#scorm_flag
        row[23].to_s.present? ? row[23].to_s : nil,#out_content_flag
        row[16].to_s.present? ? row[16].to_s : nil,#created_at
        row[17].to_s.present? ? row[17].to_s : nil#updated_at
      )
      
      content_attachment(row,mysql)
    end
   
  end

  # 将下载的subject_contents.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw20130718
  def self.input_subject_contents( mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/subject_contents.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO subject_contents "
    sql << "(sc_old_id,subject_id,content_id,deleted,created_at,updated_at)"
    sql << "VALUES(?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
    
      row_index += 1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入
      subject_content_id = []
      mysql.query("SELECT id FROM subject_contents where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|w| subject_content_id << w}
      subject_content_id = subject_content_id.to_s
      #查找到对应的content_id
      if row[2].to_s.present?
        content_id =[]
        mysql.query("SELECT id FROM contents where sc_old_id =(#{row[2].to_s}) ORDER BY id DESC LIMIT 1").each {|r| content_id << r}
        content_deleted = []
        mysql.query("SELECT deleted FROM contents where sc_old_id =(#{row[2].to_s}) ORDER BY id DESC LIMIT 1").each {|c| content_deleted << c}
        content_deleted = content_deleted.to_s
      end
      #查找到相应的subject_id
      if row[1].to_s.present?
        subject_id = []
        mysql.query("SELECT id FROM subjects where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|s| subject_id << s}
        sub_deleted = []
        mysql.query("SELECT deleted FROM subjects where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|s| sub_deleted << s}
      end
      deleted = ""
      if sub_deleted.to_s == "1"
        deleted = "1"
      else
        deleted = row[3].to_s
      end
      if subject_content_id.blank?
        st.execute(
          row[0].to_s.present? ? row[0].to_s : nil,
          subject_id.to_s.present? ? subject_id.to_s : nil,
          content_id.to_s.present? ? content_id.to_s : nil,
          deleted.to_s.present? ? deleted.to_s : nil,
          row[4].to_s.present? ? row[4].to_s : nil,
          row[5].to_s.present? ? row[5].to_s : nil
        )
        #如果content被删除了则不创建lesson
        if content_deleted == "0"
          #input lesson
          input_lesson(row, mysql)
        end
      end

    end
  end

  # 导入lesson
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zq20130814
  def self.input_lesson(row, mysql)
    #subject_id = row[1].to_s
    #content_id = row[2].to_s
    #导入统和之后的subject 的id
    subject_id = []
    mysql.query("SELECT id FROM subjects where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|w| subject_id << w}
    subject_id = subject_id.to_s
    #导入相应的deleted
    deleted = []
    mysql.query("SELECT deleted FROM subjects where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|s| deleted << s}

    #导入统和之后的content 的id
    content_id = []
    mysql.query("SELECT id FROM contents where sc_old_id =(#{row[2].to_s}) ORDER BY id DESC LIMIT 1").each {|w| content_id << w}
    content_id = content_id.to_s
    
    #lesson 名 = content 名
    name = []
    mysql.query("SELECT name FROM contents where id =(#{content_id}) ORDER BY id DESC LIMIT 1").each {|w| name << w}
    name = name.to_s
    #lesson 回数
    period = []
    mysql.query("SELECT COUNT(id) FROM lessons where subject_id =(#{subject_id}) ORDER BY id DESC LIMIT 1").each {|w| period << w}
    period = period.to_s
    period = period.to_i + 1

    sql = "INSERT INTO lessons "
    sql << "(subject_id,name,period,study_time,deleted,created_at,updated_at)"
    sql << "VALUES(?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    st.execute(
      subject_id.present? ? subject_id : nil,
      name.present? ? name : nil,
      period.present? ? period : nil,
      nil,
      deleted.to_s.present? ? deleted.to_s : nil,
      row[4].to_s.present? ? row[4].to_s : nil,
      row[5].to_s.present? ? row[5].to_s : nil
    )
    input_lesson_contents(row, mysql,subject_id, period)
  end

  # 导入lesson
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zq20130814
  def self.input_lesson_contents(row, mysql, subject_id, period)
    #subject_id = row[1].to_s
    #content_id = row[2].to_s
    #导入统和之后的lesson 的id
    lesson_id = []
    mysql.query("SELECT id FROM lessons where subject_id =#{subject_id} and period = #{period} ORDER BY id DESC LIMIT 1").each {|w| lesson_id << w}
    lesson_id = lesson_id.to_s
    #导入相应的deleted
    deleted = []
    mysql.query("SELECT deleted FROM subjects where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|s| deleted << s}
    #导入统和之后的content 的id
    content_id = []
    mysql.query("SELECT id FROM contents where sc_old_id =(#{row[2].to_s}) ORDER BY id DESC LIMIT 1").each {|w| content_id << w}
    content_id = content_id.to_s

    sql = "INSERT INTO lesson_contents "
    sql << "(lesson_id,content_id,deleted,created_at,updated_at)"
    sql << "VALUES(?,?,?,?,?)"
    st = mysql.prepare(sql)
    st.execute(
      lesson_id.present? ? lesson_id : nil,
      content_id.present? ? content_id : nil,
      deleted.to_s.present? ? deleted.to_s : nil,
      row[4].to_s.present? ? row[4].to_s : nil,
      row[5].to_s.present? ? row[5].to_s : nil
    )
  end

  # 将下载的libraries.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by wxx20130718
  def self.input_libraries(mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/libraries.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO libraries "
    sql << "(sc_old_id,course_id,title,file_name,file_path,deleted,created_at,updated_at,open_status,url,memo,sort,download_flag)"
    sql << "VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
    
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入
      library_id = []
      mysql.query("SELECT id FROM libraries where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|l| library_id << l}
      library_id = library_id.to_s
      next if library_id.present?
      #查找到course_id
      course_id = []
      mysql.query("SELECT id FROM courses where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|c| course_id << c}
      course_id = course_id.to_s
      #execute
      st.execute(
        row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
        course_id.present? ? course_id : nil,#course_id
        row[2].to_s.present? ? row[2].to_s : nil,#title
        row[3].to_s.present? ? row[3].to_s : nil,#file_name
        row[4].to_s.present? ? row[4].to_s : nil,#file_path
        row[5].to_s.present? ? row[5].to_s : nil,#deleted
        row[6].to_s.present? ? row[6].to_s : nil,#created_at
        row[7].to_s.present? ? row[7].to_s : nil,#updated_at
        row[8].to_s.present? ? row[8].to_s : nil,#open_status
        row[9].to_s.present? ? row[9].to_s : nil,#url
        row[10].to_s.present? ? row[10].to_s : nil,#memo
        row[11].to_s.present? ? row[11].to_s : nil,#sort
        1#download_flag
      )
    end
  end
  # 将下载的exams.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by wxx20130718
  def self.input_exams(mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/exams.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO exams "
    sql << "(sc_old_id,course_id,name,status,deleted,created_at,updated_at,sort,eligible)"
    sql << "VALUES(?,?,?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入
      exam_id = []
      mysql.query("SELECT id FROM exams where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|e| exam_id << e}
      exam_id = exam_id.to_s
      next if exam_id.present?
      #查找到course_id
      course_id = []
      mysql.query("SELECT id FROM courses where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|c| course_id << c}
      course_id = course_id.to_s
      #execute
      st.execute(
        row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
        course_id.present? ? course_id : nil,#course_id
        row[3].to_s.present? ? row[3].to_s : nil,#name
        row[4].to_s.present? ? row[4].to_s : nil,#status
        row[5].to_s.present? ? row[5].to_s : nil,#deleted
        row[6].to_s.present? ? row[6].to_s : nil,#created_at
        row[7].to_s.present? ? row[7].to_s : nil,#updated_at
        row[8].to_s.present? ? row[8].to_s : nil,#sort
        row[9].to_s.present? ? row[9].to_s : nil#eligible
      )
    end
  end

  # 将下载的free_pages导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130718
  def self.input_free_pages( mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/free_pages.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO free_pages "
    sql << "(sc_old_id,category_id,name,part_flag,parent_name,title,`keyword`,`key`,`show`,deleted,created_at,updated_at,body,admin_id,head_link_tag)"
    sql << "VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      #第一行不导入
      row_index += 1
      #如果这个free_pages已经导入了，就不要再导入了
      next if row_index == 1

      input_log.info "===========#{row_index}============"

      #判断是否已经导入、如果已经导入则不再导入
      free_page_id = []
      mysql.query("SELECT id FROM free_pages where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|w| free_page_id << w}
      free_page_id = free_page_id.to_s
      #查找到相应的admin_id对应的admin的新id
      admin_id = []
      mysql.query("SELECT id FROM admins where sc_old_id =(#{row[13].to_s}) ORDER BY id DESC LIMIT 1").each {|r| admin_id << r}
      if free_page_id.blank?
        st.execute(
          row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
          row[1].to_s.present? ? row[1].to_s : nil,#category_id
          row[2].to_s.present? ? row[2].to_s : nil,#name
          row[3].to_s.present? ? row[3].to_s : nil,#part_flag
          row[4].to_s.present? ? row[4].to_s : nil,#parent_name
          row[5].to_s.present? ? row[5].to_s : nil,#title
          row[6].to_s.present? ? row[6].to_s : nil,#keyword
          row[7].to_s.present? ? row[7].to_s : nil,#key
          row[8].to_s.present? ? row[8].to_s : nil,#show
          row[9].to_s.present? ? row[9].to_s : nil,#deleted
          row[10].to_s.present? ? row[10].to_s : nil,#created_at
          row[11].to_s.present? ? row[11].to_s : nil, #updated_at
          row[12].to_s.present? ? row[12].to_s : nil,#body
          admin_id.to_s.present? ? admin_id.to_s : nil,#admin_id
          row[14].to_s.present? ? row[14].to_s : nil #head_link_tag
        )
      end
    end
  end

  # 将下载的将content的附件导入attachment中
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw20130719
  def self.content_attachment(row,mysql)
    sql = "INSERT INTO attachments "
    sql << "(sc_old_id,file_name,file_path,deleted,created_at,updated_at,content_type)"
    sql << "VALUES(?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    #找到content_id判断是否已经导入
    content_id = []
    mysql.query("SELECT id FROM contents where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|e| content_id << e}
    content_id = content_id.to_s
    file1_name = row[10].present? ? row[10].split("/").last : nil
    file2_name = row[11].present? ? row[11].split("/").last : nil
    file3_name = row[12].present? ? row[12].split("/").last : nil
    if content_id.present?
      #video
      if row[4].to_s == "1"
        st.execute(
          row[0].to_s.present? ? row[0].to_s : nil,
          row[9].to_s.present? ? row[9].to_s : nil,
          row[9].to_s.present? ? row[9].to_s : nil,
          row[7].to_s.present? ? row[7].to_s : nil,
          row[16].to_s.present? ? row[16].to_s : nil,
          row[17].to_s.present? ? row[17].to_s : nil,
          "1"
        )
        content_and_attachement(content_id,row,mysql)
      elsif row[4].to_s == "2"
        #file_path1
        if row [10].to_s.present?
          st.execute(
            row[0].to_s.present? ? row[0].to_s : nil,
            row[24].to_s.present? ? row[24].to_s : file1_name,
            row[10].to_s.present? ? row[10].to_s : nil,
            row[7].to_s.present? ? row[7].to_s : nil,
            row[16].to_s.present? ? row[16].to_s : nil,
            row[17].to_s.present? ? row[17].to_s : nil,
            "file_path1"
          )
          content_and_attachement(content_id,row,mysql)
        end
        #file_path2
        if row[11].to_s.present?
          st.execute(
            row[0].to_s.present? ? row[0].to_s : nil,
            row[25].to_s.present? ? row[25].to_s : file2_name,
            row[11].to_s.present? ? row[11].to_s : nil,
            row[7].to_s.present? ? row[7].to_s : nil,
            row[16].to_s.present? ? row[16].to_s : nil,
            row[17].to_s.present? ? row[17].to_s : nil,
            "file_path2"
          )
          content_and_attachement(content_id,row,mysql)
        end
        #file_path3
        if row[12].to_s.present?
          st.execute(
            row[0].to_s.present? ? row[0].to_s : nil,
            row[26].to_s.present? ? row[26].to_s : file3_name,
            row[12].to_s.present? ? row[12].to_s : nil,
            row[7].to_s.present? ? row[7].to_s : nil,
            row[16].to_s.present? ? row[16].to_s : nil,
            row[17].to_s.present? ? row[17].to_s : nil,
            "file_path3"
          )
          content_and_attachement(content_id,row,mysql)
        end
      elsif row[4].to_s == "3"
        #video
        if row[9].to_s.present?
          st.execute(
            row[0].to_s.present? ? row[0].to_s : nil,
            row[9].to_s.present? ? row[9].to_s : nil,
            row[9].to_s.present? ? row[9].to_s : nil,
            row[7].to_s.present? ? row[7].to_s : nil,
            row[16].to_s.present? ? row[16].to_s : nil,
            row[17].to_s.present? ? row[17].to_s : nil,
            "1"
          )
          content_and_attachement(content_id,row,mysql)
        end
        #file_path1
        if row [10].to_s.present?
          st.execute(
            row[0].to_s.present? ? row[0].to_s : nil,
            row[24].to_s.present? ? row[24].to_s : file1_name,
            row[10].to_s.present? ? row[10].to_s : nil,
            row[7].to_s.present? ? row[7].to_s : nil,
            row[16].to_s.present? ? row[16].to_s : nil,
            row[17].to_s.present? ? row[17].to_s : nil,
            "file_path1"
          )
          content_and_attachement(content_id,row,mysql)
        end
        #file_path2
        if row[11].to_s.present?
          st.execute(
            row[0].to_s.present? ? row[0].to_s : nil,
            row[25].to_s.present? ? row[25].to_s : file2_name,
            row[11].to_s.present? ? row[11].to_s : nil,
            row[7].to_s.present? ? row[7].to_s : nil,
            row[16].to_s.present? ? row[16].to_s : nil,
            row[17].to_s.present? ? row[17].to_s : nil,
            "file_path2"
          )
          content_and_attachement(content_id,row,mysql)
        end
        #file_path3
        if row[12].to_s.present?
          st.execute(
            row[0].to_s.present? ? row[0].to_s : nil,
            row[26].to_s.present? ? row[26].to_s : file3_name,
            row[12].to_s.present? ? row[12].to_s : nil,
            row[7].to_s.present? ? row[7].to_s : nil,
            row[16].to_s.present? ? row[16].to_s : nil,
            row[17].to_s.present? ? row[17].to_s : nil,
            "file_path3"
          )
          content_and_attachement(content_id,row,mysql)
        end
      end
    end
  end

  # 将下载的将content的附件导入content_attachments中
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw20130722
  def self.content_and_attachement(content_id,row,mysql)
    sql2 = "INSERT INTO content_attachments "
    sql2 << "(content_id, attachment_id, deleted, created_at, updated_at)"
    sql2 << "VALUES(?,?,?,?,?)"
    st = mysql.prepare(sql2)
    #查找到content的存入的对应的attachment的id
    attachment_id = []
    mysql.query("SELECT id FROM attachments where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|e| attachment_id << e}
    attachment_id = attachment_id.to_s
    #插入中间表数据
    if attachment_id.present?
      st.execute(
        content_id.present? ? content_id.to_s : nil,
        attachment_id.to_s.present? ? attachment_id.to_s : nil,
        row[7].to_s.present? ? row[7].to_s : nil,
        row[16].to_s.present? ? row[16].to_s : nil,
        row[17].to_s.present? ? row[17].to_s : nil
      )
    end
  end
 
  # 将下载的exam_titles.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by wxx20130719
  def self.input_exam_titles(mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/exam_titles.csv"
    #prepare
    return unless File.exist?(old_file)
    exam_title_sql = "INSERT INTO exam_titles "
    exam_title_sql << "(sc_old_id,exam_id,title,content,deleted,created_at,updated_at,sort)"
    exam_title_sql << "VALUES(?,?,?,?,?,?,?,?)"
    st = mysql.prepare(exam_title_sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入
      exam_title_id = []
      mysql.query("SELECT id FROM exam_titles where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|e| exam_title_id << e}
      exam_title_id = exam_title_id.to_s
      next if exam_title_id.present?
      #查找到exam_id
      exam_id = []
      mysql.query("SELECT id FROM exams where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|e| exam_id << e}
      exam_id = exam_id.to_s
      #execute
      st.execute(
        row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
        exam_id.present? ? exam_id : nil,#exam_id
        row[2].to_s.present? ? row[2].to_s : nil,#title
        row[3].to_s.present? ? row[3].to_s : nil,#content
        row[4].to_s.present? ? row[4].to_s : nil,#deleted
        row[5].to_s.present? ? row[5].to_s : nil,#created_at
        row[6].to_s.present? ? row[6].to_s : nil,#updated_at
        row[7].to_s.present? ? row[7].to_s : nil#sort
      )
    end
  end

  # enquete的导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw20130719
  def self.input_enquetes(mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/enquetes.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO enquetes "
    sql << "(sc_old_id,course_id,live_id,name,status,sort,deleted,created_at,updated_at,created_id,edit_flag)"
    sql << "VALUES(?,?,?,?,?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入
      enquete_id = []
      mysql.query("SELECT id FROM enquetes where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|l| enquete_id << l}
      enquete_id = enquete_id.to_s
      next if enquete_id.present?
      #查找到created_id
      created_id = []
      mysql.query("SELECT id FROM admins where sc_old_id =(#{row[9].to_s}) ORDER BY id DESC LIMIT 1").each {|c| created_id << c}
      #execute
      st.execute(
        row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
        row[1].to_s.present? ? row[1].to_s : nil,#course_id
        row[2].to_s.present? ? row[2].to_s : nil,#live_id
        row[3].to_s.present? ? row[3].to_s : nil,#name
        row[4].to_s.present? ? row[4].to_s : nil,#status
        row[5].to_s.present? ? row[5].to_s : nil,#sort
        row[6].to_s.present? ? row[6].to_s : nil,#deleted
        row[7].to_s.present? ? row[7].to_s : nil,#created_at
        row[8].to_s.present? ? row[8].to_s : nil,#updated_at
        created_id.to_s.present? ? created_id.to_s : nil,#created_id
        0
      )
    end
  end

  # enquete_users的导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw20130719
  def self.input_enquete_users(mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/enquete_users.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO enquete_users "
    sql << "(sc_old_id,enquete_id,user_id,deleted,created_at,updated_at)"
    sql << "VALUES(?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入
      enquete_user_id = []
      mysql.query("SELECT id FROM enquete_users where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|l| enquete_user_id << l}
      enquete_user_id = enquete_user_id.to_s
      next if enquete_user_id.present?
      #查找到enquete_id
      enquete_id = []
      mysql.query("SELECT id FROM enquetes where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|c| enquete_id << c}
      #查找到相应的user_id
      user_id =[]
      mysql.query("SELECT id FROM users where sc_old_id =(#{row[2].to_s}) ORDER BY id DESC LIMIT 1").each {|u| user_id << u}
      #execute
      st.execute(
        row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
        enquete_id.to_s.present? ? enquete_id.to_s : nil,#enquete_id
        user_id.to_s.present? ? user_id.to_s : nil,#user_id
        row[3].to_s.present? ? row[3].to_s : nil,#deleted
        row[4].to_s.present? ? row[4].to_s : nil,#created_at
        row[5].to_s.present? ? row[5].to_s : nil#updated_at
      )
    end
    
  end

  # enquete_courses的导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw20130719
  def self.input_enquete_courses(mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/enquete_courses.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO enquete_courses "
    sql << "(sc_old_id,enquete_id,course_id,deleted,created_at,updated_at)"
    sql << "VALUES(?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入
      enquete_course_id = []
      mysql.query("SELECT id FROM enquete_courses where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|l| enquete_course_id << l}
      enquete_course_id = enquete_course_id.to_s
      next if enquete_course_id.present?
      #查找到enquete_id
      enquete_id = []
      mysql.query("SELECT id FROM enquetes where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|c| enquete_id << c}
      #查找到相应的user_id
      course_id =[]
      mysql.query("SELECT id FROM courses where sc_old_id =(#{row[2].to_s}) ORDER BY id DESC LIMIT 1").each {|u| course_id << u}
      #execute
      st.execute(
        row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
        enquete_id.to_s.present? ? enquete_id.to_s : nil,#enquete_id
        course_id.to_s.present? ? course_id.to_s : nil,#course_id
        row[3].to_s.present? ? row[3].to_s : nil,#deleted
        row[4].to_s.present? ? row[4].to_s : nil,#created_at
        row[5].to_s.present? ? row[5].to_s : nil#updated_at
      )
    end
    
  end

  # enquete_questions的导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw20130719
  def self.input_enquete_questions(mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/enquete_questions.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO enquete_questions "
    sql << "(sc_old_id,enquete_id,sort,code,title,question_type,description,explanation,score,deleted,created_at,updated_at,stats)"
    sql << "VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入
      enquete_question_id = []
      mysql.query("SELECT id FROM enquete_questions where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|l| enquete_question_id << l}
      enquete_question_id = enquete_question_id.to_s
      next if enquete_question_id.present?
      #查找到enquete_id
      enquete_id = []
      mysql.query("SELECT id FROM enquetes where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|c| enquete_id << c}
      #execute
      st.execute(
        row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
        enquete_id.to_s.present? ? enquete_id.to_s : nil,#enquete_id
        row[2].to_s.present? ?  row[2].to_s : nil,#sort
        row[3].to_s.present? ? row[3].to_s : nil,#code
        row[4].to_s.present? ? row[4].to_s : nil,#title
        row[5].to_s.present? ? row[5].to_s : nil,#question_type
        row[6].to_s.present? ? row[6].to_s : nil,#description
        row[7].to_s.present? ? row[7].to_s : nil,#explanation
        row[8].to_s.present? ? row[8].to_s : nil,#score
        row[9].to_s.present? ? row[9].to_s : nil,#deleted
        row[10].to_s.present? ? row[10].to_s : nil,#created_at
        row[11].to_s.present? ? row[11].to_s : nil,#updated_at
        row[12].to_s.present? ? row[12].to_s : nil#stats
      )
    end
    
  end


  # enquete_question_choices的导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw20130719
  def self.input_enquete_question_choices(mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/enquete_questions_choices.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO enquete_question_choices "
    sql << "(sc_old_id,enquete_question_id,content,correct,deleted,created_at,updated_at,stats)"
    sql << "VALUES(?,?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入
      enquete_question_choice_id = []
      mysql.query("SELECT id FROM enquete_question_choices where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|l| enquete_question_choice_id << l}
      enquete_question_choice_id = enquete_question_choice_id.to_s
      next if enquete_question_choice_id.present?
      #查找到enquete_question_id
      enquete_question_id = []
      mysql.query("SELECT id FROM enquete_questions where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|c| enquete_question_id << c}
      #execute
      st.execute(
        row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
        enquete_question_id.to_s.present? ? enquete_question_id.to_s : nil,#enquete_question_id
        row[2].to_s.present? ?  row[2].to_s : nil,#content
        row[3].to_s.present? ? row[3].to_s : nil,#correct
        row[4].to_s.present? ? row[4].to_s : nil,#deleted
        row[5].to_s.present? ? row[5].to_s : nil,#created_at
        row[6].to_s.present? ? row[6].to_s : nil,#updated_at
        row[7].to_s.present? ? row[7].to_s : nil#stats
       
      )
    end
  end

  # 将下载的ckeditor_assets导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130719
  def self.input_ckeditor_assets(mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/ckeditor_assets.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO ckeditor_assets "
    sql << "(sc_old_id,data_file_name,data_content_type,data_file_size,assetable_id,assetable_type,type,guid,locale,user_id,created_at,updated_at)"
    sql << "VALUES(?,?,?,?,?,?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      #第一行不导入
      row_index += 1
      #如果这个ckeditor_assets已经导入了，就不要再导入了
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入、如果已经导入则不再导入
      ckeditor_asset_id = []
      mysql.query("SELECT id FROM ckeditor_assets where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|w| ckeditor_asset_id << w}
      ckeditor_asset_id = ckeditor_asset_id.to_s
      #查找到相应的admin_id对应的admin的新id
      admin_id = []
      mysql.query("SELECT id FROM admins where sc_old_id =(#{row[9].to_s}) ORDER BY id DESC LIMIT 1").each {|r| admin_id << r}
      if ckeditor_asset_id.blank?
        st.execute(
          row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
          row[1].to_s.present? ? row[1].to_s : nil,#data_file_name
          row[2].to_s.present? ? row[2].to_s : nil,#data_content_type
          row[3].to_s.present? ? row[3].to_s : nil,#data_file_size
          row[4].to_s.present? ? row[4].to_s : nil,#assetable_id
          row[5].to_s.present? ? row[5].to_s : nil,#assetable_type
          row[6].to_s.present? ? row[6].to_s : nil,#type
          row[7].to_s.present? ? row[7].to_s : nil,#guid
          row[8].to_s.present? ? row[8].to_s : nil,#locale
          admin_id.to_s.present? ? admin_id.to_s : nil,#admin_id
          row[10].to_s.present? ? row[10].to_s : nil,#created_at
          row[11].to_s.present? ? row[11].to_s : nil #updated_at
        )
      end
    end
  end

  # 将下载的course_teachers导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130719
  def self.input_course_teachers(mysql, csv_file_path ,school_id,input_log)
    old_file = csv_file_path + "/course_teachers.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO course_teachers"
    sql << "(sc_old_id,course_id,school_id,teacher_id,mailsend_flag,created_at,updated_at,deleted)"
    sql << "VALUES(?,?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      #第一行不导入
      row_index += 1
      #如果这个course_teachers已经导入了，就不要再导入了
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入、如果已经导入则不再导入
      course_teacher_id = []
      mysql.query("SELECT id FROM course_teachers where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|w| course_teacher_id << w}
      course_teacher_id = course_teacher_id.to_s
      #查找到相应的course_id对应的course的新id
      course_id = []
      mysql.query("SELECT id FROM courses where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|r| course_id << r}
      #查找到相应的teacher_id对应的admin的新id
      teacher_id = []
      mysql.query("SELECT id FROM admins where sc_old_id =(#{row[3].to_s}) ORDER BY id DESC LIMIT 1").each {|r| teacher_id << r}

      if course_teacher_id.blank?
        st.execute(
          row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
          course_id.to_s.present? ? course_id.to_s : nil,#course_id
          school_id,#school_id
          teacher_id.to_s.present? ? teacher_id.to_s : nil, #teacher_id
          row[4].to_s.present? ? row[4].to_s : nil,#mailsend_flag
          row[5].to_s.present? ? row[5].to_s : nil,#created_at
          row[6].to_s.present? ? row[6].to_s : nil,#updated_at
          row[7].to_s.present? ? row[7].to_s : nil #deleted
        )
      end
    end
  end
  # 将下载的exam_questions.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by wxx20130719
  def self.input_exam_questions(mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/exam_questions.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO exam_questions "
    sql << "(sc_old_id, exam_id, sort, code, title, question_type, description, explanation, score, deleted, created_at, updated_at, exam_title_id)"
    sql << "VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入
      exam_question_id = []
      mysql.query("set sql_mode=''")
      mysql.query("SELECT id FROM exam_questions where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|e| exam_question_id << e}
      exam_question_id = exam_question_id.to_s
      next if exam_question_id.present?
      #查找到exam_id
      exam_id = []
      mysql.query("SELECT id FROM exams where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|e| exam_id << e} if row[1].present?
      exam_id = exam_id.to_s
      #查找到exam_title_id
      exam_title_id = []
      mysql.query("SELECT id FROM exam_titles where sc_old_id =(#{row[12].to_s}) ORDER BY id DESC LIMIT 1").each {|e| exam_title_id << e} if row[12].present?
      exam_title_id = exam_title_id.to_s
      #execute
      st.execute(
        row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
        exam_id.to_s.present? ? exam_id : nil,#exam_id
        row[2].to_s.present? ? row[2].to_s : nil,#sort
        row[3].to_s.present? ? row[3].to_s : nil,#code
        row[4].to_s.present? ? row[4].to_s : nil,#title
        row[5].to_s.present? ? row[5].to_s : nil,#question_type
        row[6].to_s.present? ? row[6].to_s : nil,#description
        row[7].to_s.present? ? row[7].to_s : nil,#explanation
        row[8].to_s.present? ? row[8].to_s : nil,#score
        row[9].to_s.present? ? row[9].to_s : nil,#deleted
        row[10].to_s.present? ? row[10].to_s : nil,#created_at
        row[11].to_s.present? ? row[11].to_s : nil,#updated_at
        exam_title_id#exam_title_id
      )
    end
  end


  # 将下载的exam_question_choices.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by wxx20130719
  def self.input_exam_question_choices(mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/exam_question_choices.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO exam_question_choices "
    sql << "(sc_old_id, exam_question_id, content, correct, deleted, created_at, updated_at, photo_path)"
    sql << "VALUES(?,?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入
      exam_question_choice_id = []
      mysql.query("SELECT id FROM exam_question_choices where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|e| exam_question_choice_id << e}
      exam_question_choice_id = exam_question_choice_id.to_s
      next if exam_question_choice_id.present?
      #查找到exam_question_id
      exam_question_id = []
      mysql.query("SELECT id FROM exam_questions where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|e| exam_question_id << e}
      exam_question_id = exam_question_id.to_s
      #execute
      st.execute(
        row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
        exam_question_id.present? ? exam_question_id : nil,#exam_question_id
        row[2].to_s.present? ? row[2].to_s : nil,#content
        row[3].to_s.present? ? row[3].to_s : nil,#correct
        row[4].to_s.present? ? row[4].to_s : nil,#deleted
        row[5].to_s.present? ? row[5].to_s : nil,#created_at
        row[6].to_s.present? ? row[6].to_s : nil,#updated_at
        row[7].to_s.present? ? row[7].to_s : nil#photo_path
      )
    end
  end

  # 将下载的homeworks.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by wxx20130719
  def self.input_homeworks(mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/homeworks.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO homeworks "
    sql << "(sc_old_id, course_id, deleted, created_at, updated_at, comment, title)"
    sql << "VALUES(?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入
      homework_id = []
      mysql.query("SELECT id FROM homeworks where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|e| homework_id << e}
      homework_id = homework_id.to_s
      next if homework_id.present?
      #查找到course_id
      course_id = []
      mysql.query("SELECT id FROM courses where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|e| course_id << e}
      course_id = course_id.to_s
      #execute
      st.execute(
        row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
        course_id.present? ? course_id : nil,#course_id
        row[2].to_s.present? ? row[2].to_s : nil,#deleted
        row[3].to_s.present? ? row[3].to_s : nil,#created_at
        row[4].to_s.present? ? row[4].to_s : nil,#updated_at
        row[5].to_s.present? ? row[5].to_s : nil,#comment
        row[6].to_s.present? ? row[6].to_s : nil#title
      )
    end
  end

  # 将下载的contact_courses.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by wxx20130719
  def self.input_contact_courses(mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/contact_courses.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO contact_courses "
    sql << "(sc_old_id, course_id, contact_course_id, deleted, created_at, updated_at, show_stream)"
    sql << "VALUES(?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入
      contact_id = []
      mysql.query("SELECT id FROM contact_courses where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|e| contact_id << e}
      contact_id = contact_id.to_s
      next if contact_id.present?
      #查找到course_id
      course_id = []
      mysql.query("SELECT id FROM courses where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|e| course_id << e}
      course_id = course_id.to_s
      #查找到contact_course_id
      contact_course_id = []
      mysql.query("SELECT id FROM courses where sc_old_id =(#{row[2].to_s}) ORDER BY id DESC LIMIT 1").each {|e| contact_course_id << e}
      contact_course_id = contact_course_id.to_s
      #execute
      st.execute(
        row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
        course_id.present? ? course_id : nil,#course_id
        contact_course_id.to_s.present? ? contact_course_id.to_s : nil,#contact_course_id
        row[3].to_s.present? ? row[3].to_s : nil,#deleted
        row[4].to_s.present? ? row[4].to_s : nil,#created_at
        row[5].to_s.present? ? row[5].to_s : nil,#updated_at
        row[6].to_s.present? ? row[6].to_s : nil#show_stream
      )
    end
  end

  # 将下载的comments.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by wxx20130719
  def self.input_comments(school_id, mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/comments.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO comments "
    sql << "(sc_old_id, user_id, course_id, school_id, content, deleted, created_at, updated_at, facebook_flag, twitter_flag, mixi_flag)"
    sql << "VALUES(?,?,?,?,?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入
      comment_id = []
      mysql.query("SELECT id FROM comments where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|e| comment_id << e}
      comment_id = comment_id.to_s
      next if comment_id.present?
      #查找到course_id
      course_id = []
      mysql.query("SELECT id FROM courses where sc_old_id =(#{row[2].to_s}) ORDER BY id DESC LIMIT 1").each {|e| course_id << e}
      course_id = course_id.to_s
      #查找到user_id
      user_id = []
      mysql.query("SELECT id FROM users where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|e| user_id << e}
      user_id = user_id.to_s
      #execute
      st.execute(
        row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
        user_id.present? ? user_id : nil,#user_id
        course_id.present? ? course_id : nil,#course_id
        school_id.present? ? school_id : nil,#school_id
        row[4].to_s.present? ? row[4].to_s : nil,#content
        row[5].to_s.present? ? row[5].to_s : nil,#deleted
        row[6].to_s.present? ? row[6].to_s : nil,#created_at
        row[7].to_s.present? ? row[7].to_s : nil,#updated_at
        row[8].to_s.present? ? row[8].to_s : nil,#facebook_flag
        row[9].to_s.present? ? row[9].to_s : nil,#twitter_flag
        row[10].to_s.present? ? row[10].to_s : nil#mixi_flag
      )
    end
  end

  # 将下载的mess_groups.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130719
  def  self.input_mess_groups(mysql, csv_file_path, school_id,input_log)
    old_file = csv_file_path + "/mess_groups.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO mess_groups "
    sql << "(sc_old_id, name, memo, deleted, created_at, updated_at, teacher_id, school_id)"
    sql << "VALUES(?,?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入
      mess_group_id = []
      mysql.query("SELECT id FROM mess_groups where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|e| mess_group_id << e}
      mess_group_id = mess_group_id.to_s
      next if mess_group_id.present?
      #查找到teacher_id
      teacher_id = []
      if row[6].to_s.present?
        mysql.query("SELECT id FROM admins where sc_old_id =(#{row[6].to_s}) ORDER BY id DESC LIMIT 1").each {|e| teacher_id << e}
      end
      teacher_id = teacher_id.to_s
      #execute
      st.execute(
        row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
        row[1].to_s.present? ? row[1].to_s : nil,#name
        row[2].to_s.present? ? row[2].to_s : nil,#memo
        row[3].to_s.present? ? row[3].to_s : nil,#deleted
        row[4].to_s.present? ? row[4].to_s : nil,#created_at
        row[5].to_s.present? ? row[5].to_s : nil,#updated_at
        teacher_id.present? ? teacher_id : nil ,#teacher_id
        school_id #school_id
      )
    end
  end

  # 将下载的user_groups.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130719
  def  self.input_user_groups(mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/user_groups.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO user_groups "
    sql << "(sc_old_id, mess_group_id, user_id, deleted, created_at, updated_at)"
    sql << "VALUES(?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入
      user_group_id = []
      mysql.query("SELECT id FROM user_groups where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|e| user_group_id << e}
      user_group_id = user_group_id.to_s
      next if user_group_id.present?
      #查找到mess_group_id
      mess_group_id = []
      mysql.query("SELECT id FROM mess_groups where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|e| mess_group_id << e}
      mess_group_id = mess_group_id.to_s
      #查找到user_id
      user_id = []
      if row[2].to_s.present?
        mysql.query("SELECT id FROM users where sc_old_id =(#{row[2].to_s}) ORDER BY id DESC LIMIT 1").each {|e| user_id << e}
      end
      user_id = user_id.to_s
      #execute
      st.execute(
        row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
        mess_group_id.present? ? mess_group_id : nil,#mess_group_id
        user_id.present? ? user_id : nil, #user_id
        row[3].to_s.present? ? row[3].to_s : nil,#deleted
        row[4].to_s.present? ? row[4].to_s : nil,#created_at
        row[5].to_s.present? ? row[5].to_s : nil #updated_at
      )
    end
  end

  # 将下载的tags.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130719
  def self.input_tags(mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/tags.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO tags "
    sql << "(sc_old_id, name)"
    sql << "VALUES(?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入
      tag_id = []
      mysql.query("SELECT id FROM tags where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|e| tag_id << e}
      tag_id = tag_id.to_s
      next if tag_id.present?
      #execute
      st.execute(
        row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
        row[1].to_s.present? ? row[1].to_s : nil #name
      )
    end
  end

  # 将下载的taggings.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130719
  def self.input_taggings(mysql,csv_file_path,input_log)
    old_file = csv_file_path + "/taggings.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO taggings "
    sql << "(sc_old_id, tag_id, taggable_id, tagger_id, tagger_type, taggable_type, context, created_at)"
    sql << "VALUES(?,?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入
      tagging_id = []
      mysql.query("SELECT id FROM taggings where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|e| tagging_id << e}
      tagging_id = tagging_id.to_s
      next if tagging_id.present?
      #查找到tag_id
      tag_id = []
      mysql.query("SELECT id FROM tags where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|e| tag_id << e}
      tag_id = tag_id.to_s
      #查找到taggable_id
      taggable_id = []
      if row[5].to_s == "Library"
        mysql.query("SELECT id FROM libraries where sc_old_id =(#{row[2].to_s}) ORDER BY id DESC LIMIT 1").each {|e| taggable_id << e}
      elsif row[5].to_s == "Enquete"
        mysql.query("SELECT id FROM enquetes where sc_old_id =(#{row[2].to_s}) ORDER BY id DESC LIMIT 1").each {|e| taggable_id << e}
      elsif row[5].to_s == "Archive"
        mysql.query("SELECT id FROM archives where sc_old_id =(#{row[2].to_s}) ORDER BY id DESC LIMIT 1").each {|e| taggable_id << e}
      elsif row[5].to_s == "Content"
        mysql.query("SELECT id FROM contents where sc_old_id =(#{row[2].to_s}) ORDER BY id DESC LIMIT 1").each {|e| taggable_id << e}
      end
      taggable_id = taggable_id.to_s

      #execute
      st.execute(
        row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
        tag_id.present? ? tag_id : nil,#tag_id
        taggable_id.present? ? taggable_id : nil,#taggable_id
        row[3].to_s.present? ? row[3].to_s : nil,#tagger_id
        row[4].to_s.present? ? row[4].to_s : nil,#tagger_type
        row[5].to_s.present? ? row[5].to_s : nil,#taggable_type
        row[6].to_s.present? ? row[6].to_s : nil,#context
        row[7].to_s.present? ? row[7].to_s : nil #created_at
      )
    end
  end

  # 将下载的purchase_logs.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zq 20130722
  def self.input_purchase_logs(mysql,csv_file_path, school_id,input_log)
    old_file = csv_file_path + "/purchase_logs.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO purchase_logs "
    sql << "(sc_old_id, user_id, purchase_id, price, from_date, to_date, deleted, created_at, updated_at, school_id, code, convenient_pay_code,
pay_status, confirm_status, payment_at, convenient_confirm_code, memo, batch_created_at, trade_error_code)"
    sql << "VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入
      p_log_id = []
      mysql.query("SELECT id FROM purchase_logs where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|e| p_log_id << e}
      p_log_id = p_log_id.to_s
      next if p_log_id.present?

      #查找到user_id
      user_id = []
      mysql.query("SELECT id FROM users where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|e| user_id << e}
      user_id = user_id.to_s

      #查找到purchase_id
      purchase_id = []
      mysql.query("SELECT id FROM purchases where sc_old_id =(#{row[2].to_s}) ORDER BY id DESC LIMIT 1").each {|e| purchase_id << e}
      purchase_id = purchase_id.to_s
      #execute
      st.execute(
        row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
        user_id.present? ? user_id : nil,        #user_id
        purchase_id.present? ? purchase_id : nil,#purchase_id
        row[3].to_s.present? ? row[3].to_s : nil,#price
        row[4].to_s.present? ? row[4].to_s : nil,#from_date
        row[5].to_s.present? ? row[5].to_s : nil,#to_date
        row[6].to_s.present? ? row[6].to_s : nil,#deleted
        row[7].to_s.present? ? row[7].to_s : nil,#created_at
        row[8].to_s.present? ? row[8].to_s : nil,#updated_at
        school_id.present? ? school_id : nil,    #school_id
        row[10].to_s.present? ? row[10].to_s : nil,#code
        row[11].to_s.present? ? row[11].to_s : nil,#convenient_pay_code
        row[12].to_s.present? ? row[12].to_s : nil, #pay_status
        row[13].to_s.present? ? row[13].to_s : nil,#confirm_status
        row[14].to_s.present? ? row[14].to_s : nil,#payment_at
        row[15].to_s.present? ? row[15].to_s : nil,#convenient_confirm_code
        row[16].to_s.present? ? row[16].to_s : nil,#memo
        row[17].to_s.present? ? row[17].to_s : nil,#batch_created_at
        row[18].to_s.present? ? row[18].to_s : nil #trade_error_code

      )
    end
  end

  # 将下载的purchase_logs.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zq 20130722
  def self.input_purchase_confirm_logs(mysql,csv_file_path, school_id,input_log)
    old_file = csv_file_path + "/purchase_confirm_logs.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO purchase_confirm_logs "
    sql << "(sc_old_id, admin_id, status, year, month, deleted, created_at, updated_at, school_id, confirm_at, send_at)"
    sql << "VALUES(?,?,?,?,?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入
      p_c_log_id = []
      mysql.query("SELECT id FROM purchase_confirm_logs where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|e| p_c_log_id << e}
      p_c_log_id = p_c_log_id.to_s
      next if p_c_log_id.present?

      #查找到admin_id
      if row[1].to_s.present?
        admin_id = []
        mysql.query("SELECT id FROM admins where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|e| admin_id << e}
        admin_id = admin_id.to_s
      else
        admin_id = nil
      end

      #execute
      st.execute(
        row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
        admin_id.present? ? admin_id : nil,      #admin_id
        row[2].to_s.present? ? row[2].to_s : nil,#status
        row[3].to_s.present? ? row[3].to_s : nil,#year
        row[4].to_s.present? ? row[4].to_s : nil,#month
        row[5].to_s.present? ? row[5].to_s : nil,#deleted
        row[6].to_s.present? ? row[6].to_s : nil,#created_at
        row[7].to_s.present? ? row[7].to_s : nil,#updated_at
        school_id.present? ? school_id : nil,    #school_id
        row[9].to_s.present? ? row[9].to_s : nil, #confirm_at
        row[10].to_s.present? ? row[10].to_s : nil#send_at
      )
    end
  end

  # subject_study_logs的导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw20130722
  def self.input_subject_study_logs(mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/subject_study_logs.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO subject_study_logs "
    sql << "(sc_old_id,obj_id,lesson_id,subject_content_id,subject_id,user_id,deleted,created_at,updated_at,`mod`,account)"
    sql << "VALUES(?,?,?,?,?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否导入
      ssl_id = []
      mysql.query("SELECT id FROM subject_study_logs where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|e| ssl_id << e}
      ssl_id = ssl_id.to_s
      next if ssl_id.present?
      #查找到相关的subject_content_id
      s_c_id = []
      mysql.query("SELECT id FROM subject_contents where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|e| s_c_id << e}
      #查找到相应的subject_id
      s_id = []
      mysql.query("SELECT id FROM subjects where sc_old_id =(#{row[2].to_s}) ORDER BY id DESC LIMIT 1").each {|e| s_id << e}
      #查找到相应的content_id
      c_id =  []
      mysql.query("select content_id from subject_contents where sc_old_id = (#{row[1].to_s} ) ORDER BY id DESC LIMIT 1").each {|c| c_id << c}
      #查找到相应的lesson_id
      l_id = []
      mysql.query("select lesson_id from lesson_contents where content_id = (select content_id from subject_contents where sc_old_id = (#{row[1].to_s} )) ORDER BY id DESC LIMIT 1").each {|e| l_id << e}
      #查找到相应的user_id
      u_id = []
      mysql.query("SELECT id FROM users where sc_old_id =(#{row[3].to_s}) ORDER BY id DESC LIMIT 1").each {|e| u_id << e}
      if  s_c_id.present? && s_id.present? && u_id.present?
        #execute
        st.execute(
          row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
          c_id.to_s.present? ? c_id.to_s : nil,
          l_id.to_s.present? ? l_id.to_s : nil, #lesson_id
          s_c_id.present? ? s_c_id.to_s : nil,      #subject_content_id
          s_id.to_s.present? ? s_id.to_s : nil,#subject_id
          u_id.to_s.present? ? u_id.to_s : nil,#user_id
          row[4].to_s.present? ? row[4].to_s : nil,#deleted
          row[5].to_s.present? ? row[5].to_s : nil,#created_at
          row[6].to_s.present? ? row[6].to_s : nil,#updated_at
          2,#model
          row[8].to_s.present? ? row[8].to_s : nil #account
        )
      end
    end
    
  end
  # 将下载的email_templates.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130722
  def self.input_email_templates(mysql, csv_file_path, school_id,input_log)
    old_file = csv_file_path + "/email_templates.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO email_templates "
    sql << "(sc_old_id,body,deleted,created_at,updated_at,title,email_type,create_id)"
    sql << "VALUES(?,?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入
      email_template_id = []
      mysql.query("SELECT id FROM email_templates where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|e| email_template_id << e}
      email_template_id = email_template_id.to_s
      next if email_template_id.present?
      #execute
      st.execute(
        row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
        row[1].to_s.present? ? row[1].to_s : nil,#body
        row[2].to_s.present? ? row[2].to_s : nil,#deleted
        row[3].to_s.present? ? row[3].to_s : nil,#created_at
        row[4].to_s.present? ? row[4].to_s : nil,#updated_at
        row[5].to_s.present? ? row[5].to_s : nil, #title
        row[6].to_s.present? ? row[6].to_s : nil, #email_type
        school_id.present? ? school_id : nil    #create_id
      )
    end
  end

  # 将下载的course_email_temps.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130722
  def self.input_course_email_temps(mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/course_email_temps.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO course_email_temps "
    sql << "(sc_old_id,course_id,email_template_id,deleted,created_at,updated_at)"
    sql << "VALUES(?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入
      course_email_temp_id = []
      mysql.query("SELECT id FROM course_email_temps where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|e| course_email_temp_id << e}
      course_email_temp_id = course_email_temp_id.to_s
      next if course_email_temp_id.present?
      #查找到course_id
      course_id = []
      mysql.query("SELECT id FROM courses where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|e| course_id << e}
      course_id = course_id.to_s
      #查找到email_template_id
      email_template_id = []
      mysql.query("SELECT id FROM email_templates where sc_old_id =(#{row[2].to_s}) ORDER BY id DESC LIMIT 1").each {|e| email_template_id << e}
      email_template_id = email_template_id.to_s
      #execute
      st.execute(
        row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
        course_id.present? ? course_id : nil,#course_id
        email_template_id.present? ? email_template_id : 0,#email_template_id
        row[3].to_s.present? ? row[3].to_s : nil,#deleted
        row[4].to_s.present? ? row[4].to_s : nil,#created_at
        row[5].to_s.present? ? row[5].to_s : nil #updated_at
      )
    end
  end

  # 将下载的infos.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130722
  def self.input_infos(mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/infos.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO infos  "
    sql << "(sc_old_id,start_date,end_date,title,content,view_flag,memo,deleted,created_at,updated_at,course_id,send_before_login,send_logined,send_backstage,created_id)"
    sql << "VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入
      info_id = []
      mysql.query("SELECT id FROM infos where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|e| info_id << e}
      info_id = info_id.to_s
      next if info_id.present?
      #查找到course_id
      course_id = []
      if row[10].present?
        mysql.query("SELECT id FROM courses where sc_old_id =(#{row[10].to_s}) ORDER BY id DESC LIMIT 1").each {|e| course_id << e}
      end
      course_id = course_id.to_s
      #查找到created_id
      created_id = []
      mysql.query("SELECT id FROM admins where sc_old_id =(#{row[14].to_s}) ORDER BY id DESC LIMIT 1").each {|e| created_id << e}
      created_id = created_id.to_s
      #execute
      st.execute(
        row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
        row[1].to_s.present? ? row[1].to_s : nil,#start_date
        row[2].to_s.present? ? row[2].to_s : nil,#end_date
        row[3].to_s.present? ? row[3].to_s : nil,#title
        row[4].to_s.present? ? row[4].to_s : nil,#content
        row[5].to_s.present? ? row[5].to_s : nil, #view_flag
        row[6].to_s.present? ? row[6].to_s : nil,#memo
        row[7].to_s.present? ? row[7].to_s : nil,#deleted
        row[8].to_s.present? ? row[8].to_s : nil,#created_at
        row[9].to_s.present? ? row[9].to_s : nil,#updated_at
        course_id.present? ? course_id : nil,#course_id
        row[11].to_s.present? ? row[11].to_s : nil,#send_before_login
        row[12].to_s.present? ? row[12].to_s : nil,#send_logined
        row[14].to_s.present? ? row[13].to_s : nil,#send_backstage
        created_id.present? ? created_id : nil #created_id
      )
    end
  end

  # 将下载的course_infos.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130722
  def self.input_course_infos(mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/course_infos.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO course_infos  "
    sql << "(sc_old_id,course_id,info_id,deleted,created_at,updated_at)"
    sql << "VALUES(?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入
      course_info_id = []
      mysql.query("SELECT id FROM course_infos where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|e| course_info_id << e}
      course_info_id = course_info_id.to_s
      next if course_info_id.present?
      #查找到course_id
      course_id = []
      mysql.query("SELECT id FROM courses where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|e| course_id << e}
      course_id = course_id.to_s
      #查找到info_id
      info_id = []
      mysql.query("SELECT id FROM infos where sc_old_id =(#{row[2].to_s}) ORDER BY id DESC LIMIT 1").each {|e| info_id << e}
      info_id = info_id.to_s
      #execute
      st.execute(
        row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
        course_id.present? ? course_id : nil,#course_id
        info_id.present? ? info_id : nil,#info_id
        row[3].to_s.present? ? row[3].to_s : nil,#deleted
        row[4].to_s.present? ? row[4].to_s : nil,#created_at
        row[5].to_s.present? ? row[5].to_s : nil #updated_at

      )
    end
  end

  # 将下载的user_login_logs.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by wxx20130722
  def self.input_user_login_logs(mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/user_login_logs.csv"
    #prepare                                           n
    return unless File.exist?(old_file)
    sql = "INSERT INTO user_login_logs "
    sql << "(sc_old_id,user_id,login_at,logout_at,deleted,created_at,updated_at)"
    sql << "VALUES(?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入
      user_login_log_id = []
      mysql.query("SELECT id FROM user_login_logs where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|u| user_login_log_id << u}
      user_login_log_id = user_login_log_id.to_s
      next if user_login_log_id.present?
      #查找到user_id
      user_id = []
      mysql.query("SELECT id FROM users where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|u| user_id << u}
      user_id = user_id.to_s
      #execute
      st.execute(
        row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
        user_id.present? ? user_id : nil,#user_id
        row[2].to_s.present? ? row[2].to_s : nil,#login_at
        row[3].to_s.present? ? row[3].to_s : nil,#logout_at
        row[4].to_s.present? ? row[4].to_s : nil,#deleted
        row[5].to_s.present? ? row[5].to_s : nil, #created_at
        row[6].to_s.present? ? row[6].to_s : nil #updated_at
      )
    end
  end

  # enquete_results的导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw20130722
  def self.input_enquete_results(mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/enquete_results.csv"
    #prepare                                      
    return unless File.exist?(old_file)
    sql = "INSERT INTO enquete_results  "
    sql << "(sc_old_id,user_id,enquete_id,total_score,deleted,created_at,updated_at)"
    sql << "VALUES(?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否导入
      e_r_id = []
      mysql.query("SELECT id FROM enquete_results where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|e| e_r_id << e}
      e_r_id = e_r_id.to_s
      next if e_r_id.present?
      #查找到相关的user_id
      u_id = []
      mysql.query("SELECT id FROM users where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|e| u_id << e}
      #查找到相关的enquete_id
      enquete_id = []
      mysql.query("SELECT id FROM enquetes where sc_old_id =(#{row[2].to_s}) ORDER BY id DESC LIMIT 1").each {|e| enquete_id << e}

      #如果两者都存在则导入
      if u_id.present? && enquete_id.present?
        st.execute(
          row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
          u_id.to_s.present? ? u_id.to_s : nil,#user_id
          enquete_id.to_s.present? ? enquete_id.to_s : nil,#enquete_id
          row[3].to_s.present? ? row[3].to_s : nil,#total_score
          row[4].to_s.present? ? row[4].to_s : nil,#deleted
          row[5].to_s.present? ? row[5].to_s : nil, #created_at
          row[6].to_s.present? ? row[6].to_s : nil #updated_at
        )
      end
    end
  end

  # enquete_result_details的导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw20130722
  def self.input_enquete_result_details(mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/enquete_result_details.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO enquete_result_details  "
    sql << "(sc_old_id,enquete_result_id,enquete_question_id,scoce,answer_choice_ids,answer_detail,deleted,created_at,updated_at)"
    sql << "VALUES(?,?,?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否导入过
      e_r_d_ids =[]
      mysql.query("SELECT id FROM enquete_results where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|e| e_r_d_ids << e}
      e_r_d_ids = e_r_d_ids.to_s
      #找到相应的enquete_result_id
      enquete_result_id = []
      mysql.query("SELECT id FROM enquete_results where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|r| enquete_result_id << r}
      #找到相应的enquete_question_id
      enquete_question_id = []
      mysql.query("SELECT id FROM enquete_questions where sc_old_id =(#{row[2].to_s}) ORDER BY id DESC LIMIT 1").each {|w| enquete_question_id << w}

      if enquete_result_id.present? && enquete_question_id.present?
        st.execute(
          row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
          enquete_result_id.to_s.present? ? enquete_result_id.to_s : nil,#enquete_result_id
          enquete_question_id.to_s.present? ? enquete_question_id.to_s : nil,#enquete_question_id
          row[3].to_s.present? ? row[3].to_s : nil,#scoce
          row[4].to_s.present? ? row[4].to_s : nil,#answer_choice_ids
          row[5].to_s.present? ? row[5].to_s : nil, #answer_detail
          row[6].to_s.present? ? row[6].to_s : nil, #deleted
          row[7].to_s.present? ? row[7].to_s : nil,#created_at
          row[8].to_s.present? ? row[8].to_s : nil#updated_at
        )

      end
    end
  end

  # 将下载的exam_result_totals.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by wxx20130722
  def self.input_exam_result_totals(mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/exam_result_totals.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO exam_result_totals "
    sql << "(sc_old_id, user_id, exam_id, all_total_score, created_at, updated_at)"
    sql << "VALUES(?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入
      exam_result_total_id = []
      mysql.query("SELECT id FROM exam_result_totals where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|u| exam_result_total_id << u}
      exam_result_total_id = exam_result_total_id.to_s
      next if exam_result_total_id.present?
      #查找到user_id
      user_id = []
      mysql.query("SELECT id FROM users where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|u| user_id << u}
      user_id = user_id.to_s
      #查找到exam_id
      exam_id = []
      mysql.query("SELECT id FROM exams where sc_old_id =(#{row[2].to_s}) ORDER BY id DESC LIMIT 1").each {|e| exam_id << e}
      exam_id = exam_id.to_s
      #execute
      st.execute(
        row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
        user_id.present? ? user_id : nil,#user_id
        exam_id.present? ? exam_id : nil,#exam_id
        row[3].to_s.present? ? row[3].to_s : nil,#all_total_score
        row[4].to_s.present? ? row[4].to_s : nil,#created_at
        row[5].to_s.present? ? row[5].to_s : nil #updated_at
      )
    end
  end

  # 将下载的file_shares.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130722
  def self.input_file_shares(mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/file_shares.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO file_shares  "
    sql << "(sc_old_id,course_id,user_id,type,title,content,sender_flag,file_path,file_name, deleted,created_at,updated_at)"
    sql << "VALUES(?,?,?,?,?,?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入
      file_share_id = []
      mysql.query("SELECT id FROM file_shares where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|e| file_share_id << e}
      file_share_id = file_share_id.to_s
      next if file_share_id.present?
      #查找到course_id
      course_id = []
      mysql.query("SELECT id FROM courses where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|e| course_id << e}
      course_id = course_id.to_s
      #查找到user_id
      user_id = []
      if row[3] == "FileTeacher"
        mysql.query("SELECT id FROM admins where sc_old_id =(#{row[2].to_s}) ORDER BY id DESC LIMIT 1").each {|e| user_id << e}
      elsif row[3] == "FileStudent"
        mysql.query("SELECT id FROM users where sc_old_id =(#{row[2].to_s}) ORDER BY id DESC LIMIT 1").each {|e| user_id << e}
      end

      user_id = user_id.to_s
      #execute
      st.execute(
        row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
        course_id.present? ? course_id : nil,#course_id
        user_id.present? ? user_id : nil,#user_id
        row[3].to_s.present? ? row[3].to_s : nil,#type
        row[4].to_s.present? ? row[4].to_s : nil,#title
        row[5].to_s.present? ? row[5].to_s : nil, #content
        row[6].to_s.present? ? row[6].to_s : nil,#sender_flag
        row[7].to_s.present? ? row[7].to_s : nil,#file_path
        row[8].to_s.present? ? row[8].to_s : nil,#file_name
        row[9].to_s.present? ? row[9].to_s : nil,#deleted
        row[10].to_s.present? ? row[10].to_s : nil,#created_at
        row[11].to_s.present? ? row[11].to_s : nil#updated_at
      )
    end
  end

  # 将下载的file_share_replies.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130722
  def self.input_file_share_replies(mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/file_share_replies.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO file_share_replies  "
    sql << "(sc_old_id,file_share_id,user_id,type,title,content,sender_flag,file_path,file_name, deleted,created_at,updated_at)"
    sql << "VALUES(?,?,?,?,?,?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入
      file_share_reply_id = []
      mysql.query("SELECT id FROM file_share_replies where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|e| file_share_reply_id << e}
      file_share_reply_id = file_share_reply_id.to_s
      next if file_share_reply_id.present?
      #查找到file_share_id
      file_share_id = []
      mysql.query("SELECT id FROM file_shares where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|e| file_share_id << e}
      file_share_id = file_share_id.to_s
      #查找到user_id
      user_id = []
      if row[3] == "FileTeacher"
        mysql.query("SELECT id FROM admins where sc_old_id =(#{row[2].to_s}) ORDER BY id DESC LIMIT 1").each {|e| user_id << e}
      elsif row[3] == "FileStudent"
        mysql.query("SELECT id FROM users where sc_old_id =(#{row[2].to_s}) ORDER BY id DESC LIMIT 1").each {|e| user_id << e}
      end

      user_id = user_id.to_s
      #execute
      st.execute(
        row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
        file_share_id.present? ? file_share_id : nil,#file_share_id
        user_id.present? ? user_id : nil,#user_id
        row[3].to_s.present? ? row[3].to_s : nil,#type
        row[4].to_s.present? ? row[4].to_s : nil,#title
        row[5].to_s.present? ? row[5].to_s : nil, #content
        row[6].to_s.present? ? row[6].to_s : nil,#sender_flag
        row[7].to_s.present? ? row[7].to_s : nil,#file_path
        row[8].to_s.present? ? row[8].to_s : nil,#file_name
        row[9].to_s.present? ? row[9].to_s : nil,#deleted
        row[10].to_s.present? ? row[10].to_s : nil,#created_at
        row[11].to_s.present? ? row[11].to_s : nil#updated_at
      )
    end
  end

  # 将下载的exam_results.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by wxx20130722
  def self.input_exam_results(mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/exam_results.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO exam_results "
    sql << "(sc_old_id, user_id, exam_id, total_score, deleted, created_at, updated_at, exam_title_id, exam_result_total_id)"
    sql << "VALUES(?,?,?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入
      exam_result_id = []
      mysql.query("SELECT id FROM exam_results where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|e| exam_result_id << e}
      exam_result_id = exam_result_id.to_s
      next if exam_result_id.present?
      #查找到user_id
      user_id = []
      mysql.query("SELECT id FROM users where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|u| user_id << u}
      user_id = user_id.to_s
      #查找到exam_id
      exam_id = []
      mysql.query("SELECT id FROM exams where sc_old_id =(#{row[2].to_s}) ORDER BY id DESC LIMIT 1").each {|e| exam_id << e}
      exam_id = exam_id.to_s
      #查找到exam_title_id
      exam_title_id = []
      mysql.query("SELECT id FROM exam_titles where sc_old_id =(#{row[7].to_s}) ORDER BY id DESC LIMIT 1").each {|e| exam_title_id << e}
      exam_title_id = exam_title_id.to_s
      #查找到exam_result_total_id
      exam_result_total_id = []
      mysql.query("SELECT id FROM exam_result_totals where sc_old_id =(#{row[8].to_s}) ORDER BY id DESC LIMIT 1").each {|e| exam_result_total_id << e} if row[8].to_s.present?
      exam_result_total_id = exam_result_total_id.to_s
      #execute
      st.execute(
        row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
        user_id.present? ? user_id : nil,#user_id
        exam_id.present? ? exam_id : nil,#exam_id
        row[3].to_s.present? ? row[3].to_s : nil,#total_score
        row[4].to_s.present? ? row[4].to_s : nil,#deleted
        row[5].to_s.present? ? row[5].to_s : nil,#created_at
        row[6].to_s.present? ? row[6].to_s : nil,#updated_at
        exam_title_id.present? ? exam_title_id : nil,#exam_title_id
        exam_result_total_id.present? ? exam_result_total_id.to_s : nil #exam_result_total_id
      )
    end
  end

  # 将下载的exam_result_details.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by wxx20130722
  def self.input_exam_result_details(mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/exam_result_details.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO exam_result_details "
    sql << "(sc_old_id, exam_result_id, exam_question_id, answer_choice_ids, scoce, answer_detail, deleted, created_at, updated_at)"
    sql << "VALUES(?,?,?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入
      exam_result_detail_id = []
      mysql.query("SELECT id FROM exam_result_details where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|e| exam_result_detail_id << e}
      exam_result_detail_id = exam_result_detail_id.to_s
      next if exam_result_detail_id.present?
      #查找到exam_result_id
      exam_result_id = []
      mysql.query("SELECT id FROM exam_results where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|e| exam_result_id << e}
      exam_result_id = exam_result_id.to_s
      #查找到exam_question_id
      exam_question_id = []
      mysql.query("SELECT id FROM exam_questions where sc_old_id =(#{row[2].to_s}) ORDER BY id DESC LIMIT 1").each {|e| exam_question_id << e}
      exam_question_id = exam_question_id.to_s
      #execute
      st.execute(
        row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
        exam_result_id.present? ? exam_result_id : nil,#exam_result_id
        exam_question_id.present? ? exam_question_id : nil,#exam_question_id
        row[3].to_s.present? ? row[3].to_s : nil,#answer_choice_ids
        row[4].to_s.present? ? row[4].to_s : nil,#scoce
        row[5].to_s.present? ? row[5].to_s : nil,#answer_detail
        row[6].to_s.present? ? row[6].to_s : nil,#deleted
        row[7].to_s.present? ? row[7].to_s : nil,#created_at
        row[8].to_s.present? ? row[8].to_s : nil #updated_at
      )
    end
  end

  # 将下载的message_folders.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by wxx20130723
  def self.input_message_folders(mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/message_folders.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO message_folders "
    sql << "(sc_old_id, name, deleted, created_at, updated_at, admin_id, user_id, sender)"
    sql << "VALUES(?,?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入
      message_folder_id = []
      mysql.query("SELECT id FROM message_folders where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|e| message_folder_id << e} if row[0].to_s.present?
      message_folder_id = message_folder_id.to_s
      next if message_folder_id.present?
      #查找到admin_id
      admin_id = []
      mysql.query("SELECT id FROM admins where sc_old_id =(#{row[5].to_s}) ORDER BY id DESC LIMIT 1").each {|a| admin_id << a} if row[5].to_s.present?
      admin_id = admin_id.to_s
      #查找到user_id
      user_id = []
      mysql.query("SELECT id FROM users where sc_old_id =(#{row[6].to_s}) ORDER BY id DESC LIMIT 1").each {|u| user_id << u} if row[6].to_s.present?
      user_id = user_id.to_s
      #execute
      st.execute(
        row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
        row[1].to_s.present? ? row[1].to_s : nil,#name
        row[2].to_s.present? ? row[2].to_s : nil,#deleted
        row[3].to_s.present? ? row[3].to_s : nil,#created_at
        row[4].to_s.present? ? row[4].to_s : nil,#updated_at
        admin_id.present? ? admin_id : nil,#admin_id
        user_id.present? ? user_id : nil,#user_id
        row[7].to_s.present? ? row[7].to_s : nil#sender
      )
    end
  end

  # 将下载的messages.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by wxx20130723
  def self.input_messages(mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/messages.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO messages "
    sql << "(sc_old_id, user_id, admin_id, title, content, deleted, created_at, updated_at, rubbish, course_id, draft, sender, mess_groups, old_id, old_message_folder_id)"
    sql << "VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入
      message_id = []
      mysql.query("SELECT id FROM messages where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|m| message_id << m} if row[0].to_s.present?
      message_id = message_id.to_s
      next if message_id.present?
      #查找到admin_id
      admin_id = []
      mysql.query("SELECT id FROM admins where sc_old_id =(#{row[2].to_s}) ORDER BY id DESC LIMIT 1").each {|a| admin_id << a} if row[2].to_s.present?
      admin_id = admin_id.to_s
      #查找到user_id
      user_id = []
      mysql.query("SELECT id FROM users where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|u| user_id << u} if row[1].to_s.present?
      user_id = user_id.to_s
      #查找到course_id
      course_id = []
      mysql.query("SELECT id FROM courses where sc_old_id =(#{row[9].to_s}) ORDER BY id DESC LIMIT 1").each {|c| course_id << c} if row[9].to_s.present?
      course_id = course_id.to_s
      #查找到mess_groups
      new_mess_groups = ''
      mess_group_ids = row[12].to_s
      mess_group_ids = mess_group_ids.split(",")
      if mess_group_ids.present?
        mess_group_ids.each do |m|
          mysql.query("SELECT id FROM mess_groups where sc_old_id =(#{m}) ORDER BY id DESC LIMIT 1").each {|m| new_mess_groups += m.to_s}
        end
      end
      #execute
      st.execute(
        row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
        user_id.present? ? user_id : nil,#user_id
        admin_id.present? ? admin_id : nil,#admin_id
        row[3].to_s.present? ? row[3].to_s : nil,#title
        row[4].to_s.present? ? to_br(row[4]) : nil,#content
        row[5].to_s.present? ? row[5].to_s : nil,#deleted
        row[6].to_s.present? ? row[6].to_s : nil,#created_at
        row[7].to_s.present? ? row[7].to_s : nil,#updated_at
        row[8].to_s.present? ? row[8].to_s : nil,#rubbish
        course_id.present? ? course_id : nil,#course_id
        row[10].to_s.present? ? row[10].to_s : nil,#draft
        row[11].to_s.present? ? row[11].to_s : nil,#sender
        new_mess_groups.present? ? new_mess_groups : nil,#mess_groups
        row[13].to_s.present? ? row[13].to_s : nil,#old_id
        row[14].to_s.present? ? row[14].to_s : nil#old_message_folder_id
      )
    end
  end

  # 将下载的receivers.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by wxx20130723
  def self.input_receivers(mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/receivers.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO receivers "
    sql << "(sc_old_id, user_id, admin_id, message_id, message_folder_id, replay_message_id, open_time, rubbish, deleted, created_at, updated_at, admin_rubbish, user_rubbish, admin_message_folder_id, real_time)"#
    sql << "VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入
      receiver_id = []
      mysql.query("SELECT id FROM receivers where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|r| receiver_id << r} if row[0].to_s.present?
      receiver_id = receiver_id.to_s
      next if receiver_id.present?
      #查找到user_id
      user_id = []
      mysql.query("SELECT id FROM users where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|u| user_id << u} if row[1].to_s.present?
      user_id = user_id.to_s
      #查找到admin_id
      admin_id = []
      mysql.query("SELECT id FROM admins where sc_old_id =(#{row[2].to_s}) ORDER BY id DESC LIMIT 1").each {|a| admin_id << a} if row[2].to_s.present?
      admin_id = admin_id.to_s
      #查找到message_id
      message_id = []
      mysql.query("SELECT id FROM messages where sc_old_id =(#{row[3].to_s}) ORDER BY id DESC LIMIT 1").each {|m| message_id << m} if row[3].to_s.present?
      message_id = message_id.to_s
      #查找到message_folder_id
      message_folder_id = []
      mysql.query("SELECT id FROM message_folders where sc_old_id =(#{row[4].to_s}) ORDER BY id DESC LIMIT 1").each {|m| message_folder_id << m} if row[4].to_s.present?
      message_folder_id = message_folder_id.to_s
      #查找到replay_message_id
      replay_message_id = []
      mysql.query("SELECT id FROM messages where sc_old_id =(#{row[5].to_s}) ORDER BY id DESC LIMIT 1").each {|r| replay_message_id << r} if row[5].to_s.present?
      replay_message_id = replay_message_id.to_s
      #查找到admin_message_folder_id
      admin_message_folder_id = []
      mysql.query("SELECT id FROM message_folders where sc_old_id =(#{row[13].to_s}) ORDER BY id DESC LIMIT 1").each {|m| admin_message_folder_id << m} if row[13].to_s.present?
      admin_message_folder_id = admin_message_folder_id.to_s
      #execute
      st.execute(
        row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
        user_id.present? ? user_id : nil,#user_id
        admin_id.present? ? admin_id : nil,#admin_id
        message_id.present? ? message_id : nil,#message_id
        message_folder_id.present? ? message_folder_id : nil,#message_folder_id
        replay_message_id.present? ? replay_message_id : nil,#replay_message_id
        row[6].to_s.present? ? row[6].to_s : nil,#open_time
        row[7].to_s.present? ? row[7].to_s : nil,#rubbish
        row[8].to_s.present? ? row[8].to_s : nil,#deleted
        row[9].to_s.present? ? row[9].to_s : nil,#created_at
        row[10].to_s.present? ? row[10].to_s : nil,#updated_at
        row[11].to_s.present? ? row[11].to_s : nil,#admin_rubbish
        row[12].to_s.present? ? row[12].to_s : nil,#user_rubbish
        admin_message_folder_id.present? ? admin_message_folder_id : nil,#admin_message_folder_id
        row[14].to_s.present? ? row[14].to_s : nil#real_time
      )
    end
  end


  # 将下载的favorites.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw20130723
  def self.input_favorites(mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/favorites.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO favorites "
    sql << "(sc_old_id, user_id, deleted, created_at, updated_at, type, obj_id, course_id)"
    sql << "VALUES(?,?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否导入
      favorite_id = []
      mysql.query("SELECT id FROM favorites where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|e| favorite_id << e}
      favorite_id = favorite_id.to_s
      next if favorite_id.present?
      #查找到相应user_id、并根据user_id查找到相应的favorite
      user_id = []
      mysql.query("SELECT id FROM users where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|w| user_id << w}
      #获取各个类型的id
      #library_id
      if row[5] == "LibraryFavorite"
        library_id = []
        mysql.query("SELECT id FROM libraries where sc_old_id =(#{row[6].to_s}) ORDER BY id DESC LIMIT 1").each {|w| library_id << w}
        library_id = library_id.to_s
        #查找到相应的course_id
        course_id = []
        mysql.query("SELECT course_id FROM libraries where id = (#{library_id.to_s}) ORDER BY id DESC LIMIT 1").each {|c| course_id << c} if library_id.to_s.present?
        course_id = course_id.to_s
        if library_id.present?
          favorite_obj(user_id,row,library_id,course_id,st)
        end
        #subject_content_id
      elsif row[5] == "SubjectContentFavorite"
        subject_content_id = []
        mysql.query("SELECT id FROM subject_contents where sc_old_id =(#{row[6].to_s}) ORDER BY id DESC LIMIT 1").each {|s| subject_content_id << s}
        subject_content_id = subject_content_id.to_s
        #查找到相应的subject_id
        subject_id = []
        mysql.query("SELECT subject_id FROM subject_contents where id =(#{subject_content_id.to_s}) ORDER BY id DESC LIMIT 1").each {|su| subject_id << su} if subject_content_id.to_s.present?
        #查找到相应的course_id
        course_id = []
        mysql.query("SELECT course_id FROM subjects where id =(#{subject_id.to_s}) ORDER BY id DESC LIMIT 1").each {|c| course_id << c}if subject_id.to_s.present?
        if subject_content_id.present?
          favorite_obj(user_id,row,subject_content_id,course_id,st)
        end
        #exam_id
      elsif row[5] == "ExamFavorite"
        exam_id = []
        mysql.query("SELECT id FROM exams where sc_old_id =(#{row[6].to_s}) ORDER BY id DESC LIMIT 1").each {|e| exam_id << e}
        exam_id = exam_id.to_s
        #查找到相应的course_id
        course_id = []
        mysql.query("SELECT course_id FROM exams where id =(#{exam_id.to_s}) ORDER BY id DESC LIMIT 1").each {|c| course_id << c} if exam_id.to_s.present?
        if exam_id.present?
          favorite_obj(user_id,row,exam_id,course_id,st)
        end
        #archive_id
      elsif row[5] == "ArchiveFavorite"
        archive_id = []
        mysql.query("SELECT id FROM archives where sc_old_id =(#{row[6].to_s}) ORDER BY id DESC LIMIT 1").each {|e| archive_id << e}
        archive_id = archive_id.to_s
        #查找到相应的live_id
        live_id = []
        mysql.query("SELECT live_id FROM archives where id =(#{archive_id.to_s}) ORDER BY id DESC LIMIT 1").each {|l| live_id << l} if archive_id.to_s.present?
        #查找到相应的course_id
        course_id = []
        mysql.query("SELECT course_id FROM lives where id =(#{live_id.to_s}) ORDER BY id DESC LIMIT 1").each {|c| course_id << c} if live_id.to_s.present?
        if archive_id.present?
          favorite_obj(user_id,row,archive_id,course_id,st)
        end
      end


    end

  end

  # 将下载的favorites.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw20130723
  def self.favorite_obj(user_id,row,id,course_id,st)
    if user_id.present?
      st.execute(
        row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
        user_id.to_s.present? ? user_id.to_s : nil,# user_id
        row[2].to_s.present? ? row[2].to_s : nil,#deleted
        row[3].to_s.present? ? row[3].to_s : nil,#created_at
        row[4].to_s.present? ? row[4].to_s : nil, #updated_at
        row[5].to_s.present? ? row[5].to_s : nil,#type
        id.to_s.present? ? id.to_s : nil,#obj_id
        course_id.to_s.present? ? course_id.to_s : nil#course_id
      )

    end

  end

  # 将下载的attachments.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw20130723
  def self.input_attachments(mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/attachments.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO attachments "
    sql << "(sc_old_id, owner_id, file_path, file_name,deleted, created_at, updated_at)"
    sql << "VALUES(?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否导入
      attachment_id = []
      mysql.query("SELECT id FROM attachments where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|e| attachment_id << e}
      attachment_id = attachment_id.to_s
      owner_id = []
      mysql.query("SELECT owner_id FROM attachments where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|o| owner_id << o}
      owner_id = owner_id.to_s
      next if attachment_id.present? && owner_id.present?
      #查找到相应的message_id
      message_id = []
      mysql.query("SELECT id FROM messages where sc_old_id =(#{row[2].to_s}) ORDER BY id DESC LIMIT 1").each {|m| message_id << m}
      st.execute(
        row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
        message_id.to_s.present? ? message_id.to_s : nil,# owner_id
        row[3].to_s.present? ? row[3].to_s : nil,#file_path
        row[4].to_s.present? ? row[4].to_s : nil,#file_name
        row[5].to_s.present? ? row[5].to_s : nil, #deleted
        row[6].to_s.present? ? row[6].to_s : nil,#created_at
        row[7].to_s.present? ? row[7].to_s : nil#updated_at
      )
    end
  end

  # 将下载的livess.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zq20130724
  def self.input_lives(mysql, csv_file_path, school_id,input_log)
    old_file = csv_file_path + "/lives.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO lives "
    sql << "(sc_old_id, exam_id, start_date, from_at, to_at, examination_open_flag, leature_file_name, leature_file_path, guid, limit_num, excel_hidden_number, deleted,
created_at, updated_at, name, course_id, library_id, create_id, school_id, teacher_id, archive_type, record_ip, record_status, auto_flag,
manual_record_status, mail_flag, view_member_count, hand_record_status, special_type)"
    sql << "VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    #course live中间表保存
    sql2 = "INSERT INTO course_lives "
    sql2 << "(sc_old_id, live_id, course_id, original_live_id, deleted, created_at, updated_at)"
    sql2 << "VALUES(?,?,?,?,?,?,?)"
    st2 = mysql.prepare(sql2)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入
      live_id = []
      mysql.query("SELECT id FROM lives where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|r| live_id << r} if row[0].to_s.present?
      live_id = live_id.to_s
      next if live_id.present?
      #查找到user_id
      course_id = []
      mysql.query("SELECT id FROM courses where sc_old_id =(#{row[15].to_s}) ORDER BY id DESC LIMIT 1").each {|u| course_id << u} if row[15].to_s.present?
      course_id = course_id.to_s
      #查找到admin_id
      create_id = []
      mysql.query("SELECT id FROM admins where sc_old_id =(#{row[17].to_s}) ORDER BY id DESC LIMIT 1").each {|a| create_id << a} if row[17].to_s.present?
      create_id = create_id.to_s
      #查找到message_id
      teacher_id = []
      mysql.query("SELECT id FROM admins where sc_old_id =(#{row[19].to_s}) ORDER BY id DESC LIMIT 1").each {|m| teacher_id << m} if row[19].to_s.present?
      teacher_id = teacher_id.to_s
      #execute
      st.execute(
        row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
        row[1].to_s.present? ? row[1].to_s : nil,#exam_id
        row[2].to_s.present? ? row[2].to_s : nil,#start_date
        row[3].to_s.present? ? row[3].to_s : nil,#from_at
        row[4].to_s.present? ? row[4].to_s : nil,#to_at
        row[5].to_s.present? ? row[5].to_s : nil,#examination_open_flag
        row[6].to_s.present? ? row[6].to_s : nil,#leature_file_name
        row[7].to_s.present? ? row[7].to_s : nil,#leature_file_path
        row[8].to_s.present? ? row[8].to_s : nil,#guid
        row[9].to_s.present? ? row[9].to_s : nil,#limit_num
        row[10].to_s.present? ? row[10].to_s : nil,#excel_hidden_number
        row[11].to_s.present? ? row[11].to_s : nil,#deleted
        row[12].to_s.present? ? row[12].to_s : nil,#created_at
        row[13].to_s.present? ? row[13].to_s : nil,#updated_at
        row[14].to_s.present? ? row[14].to_s : nil,#name
        course_id.present? ? course_id : nil,#course_id
        row[16].to_s.present? ? row[16].to_s : nil,#library_id
        create_id.present? ? create_id : nil,#create_id
        school_id.present? ? school_id : nil,#school_id
        teacher_id.present? ? teacher_id : nil,#teacher_id
        row[20].to_s.present? ? row[20].to_s : nil,#archive_type
        row[21].to_s.present? ? row[21].to_s : nil,#record_ip
        row[22].to_s.present? ? row[22].to_s : nil,#record_status
        row[23].to_s.present? ? row[23].to_s : nil,#auto_flag
        row[24].to_s.present? ? row[24].to_s : nil,#manual_record_status
        row[25].to_s.present? ? row[25].to_s : nil,#mail_flag
        row[26].to_s.present? ? row[26].to_s : nil,#view_member_count
        row[27].to_s.present? ? row[27].to_s : nil,#hand_record_status
        row[28].to_s.present? ? row[28].to_s : nil#special_type
      )

      #统和中，course和live的关系是多对多关系，需要保存中间表
      live_id = []
      mysql.query("SELECT id FROM lives where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|r| live_id << r} if row[0].to_s.present?
      live_id = live_id.to_s
      connect_course_live(course_id, live_id, st2, row)
    end
  end

  # 统和中，course和Live是多对多关系，通过中间表保存
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw20130724
  def self.connect_course_live(course_id, live_id, st2, row)
    return if course_id.blank? || live_id.blank?
    st2.execute(
      nil, #sc_old_id
      live_id.to_s.present? ? live_id.to_s : nil, # live_id
      course_id.to_s.present? ? course_id.to_s : nil, #course_id
      nil,#original_live_id
      row[11].to_s.present? ? row[11].to_s : nil,#deleted
      row[12].to_s.present? ? row[12].to_s : nil,#created_at
      row[12].to_s.present? ? row[12].to_s : nil#updated_at
    )
  end

  # 将下载的course_lives.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw20130724
  def self.input_course_lives(mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/course_lives.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO course_lives "
    sql << "(sc_old_id, live_id, course_id, original_live_id, deleted, created_at, updated_at)"
    sql << "VALUES(?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否导入过
      course_live_id = []
      mysql.query("SELECT id FROM course_lives where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|a| course_live_id << a}
      next if course_live_id.to_s.present?
      #查找到相应的course的id
      course_id = []
      mysql.query("SELECT id FROM courses where sc_old_id =(#{row[2].to_s}) ORDER BY id DESC LIMIT 1").each {|c| course_id << c}
      #查找到相应的live_id
      live_id = []
      mysql.query("SELECT id FROM lives where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|l| live_id << l}
      #如果两者都存在则执行下去
      if course_id.to_s.present? && live_id.to_s.present?
        st.execute(
          row[0].to_s.present? ? row[0].to_s : nil, #sc_old_id
          live_id.to_s.present? ? live_id.to_s : nil, # live_id
          course_id.to_s.present? ? course_id.to_s : nil, #course_id
          row[3].to_s.present? ? row[3].to_s : nil,#original_live_id
          row[4].to_s.present? ? row[4].to_s : nil,#deleted
          row[5].to_s.present? ? row[5].to_s : nil,#created_at
          row[6].to_s.present? ? row[6].to_s : nil#updated_at
        )
      end
    end

  end


  # 将下载的live_urls.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw20130724
  def self.input_live_urls(mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/lives_urls.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO live_urls "
    sql << "(sc_old_id, live_id, url, proxy_flag, deleted, created_at, updated_at)"
    sql << "VALUES(?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否导入过
      live_url_id = []
      mysql.query("SELECT id FROM live_urls where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|a| live_url_id << a} if row[0].to_s.present?
      next if live_url_id.to_s.present?
      #查找到相应的live_id
      live_id = []
      mysql.query("SELECT id FROM lives where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|l| live_id << l} if row[1].to_s.present?
      #如果两者都存在则执行下去
      if  live_id.to_s.present?
        st.execute(
          row[0].to_s.present? ? row[0].to_s : nil, #sc_old_id
          live_id.to_s.present? ? live_id.to_s : nil, # live_id
          row[2].to_s.present? ? row[2].to_s : nil, #url
          row[3].to_s.present? ? row[3].to_s : nil,#proxy_flag
          row[4].to_s.present? ? row[4].to_s : nil,#deleted
          row[5].to_s.present? ? row[5].to_s : nil,#created_at
          row[6].to_s.present? ? row[6].to_s : nil#updated_at
        )
      end

    end

  end


  # 将下载的live_urls.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw20130724
  def self.input_iframe_urls(mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/iframe_urls.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO iframe_urls "
    sql << "(sc_old_id, live_id, url, scroll_x, scroll_y, deleted, created_at, updated_at, https_flag, proxy_flag)"
    sql << "VALUES(?,?,?,?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否导入过
      iframe_url_id = []
      mysql.query("SELECT id FROM iframe_urls where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|a| iframe_url_id << a}
      next if iframe_url_id.to_s.present?
      live_id = []
      mysql.query("SELECT id FROM lives where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|l| live_id << l}
      #如果两者都存在则执行下去
      if  live_id.to_s.present?
        st.execute(
          row[0].to_s.present? ? row[0].to_s : nil, #sc_old_id
          live_id.to_s.present? ? live_id.to_s : nil, # live_id
          row[2].to_s.present? ? row[2].to_s : nil, #url
          row[3].to_s.present? ? row[3].to_s : nil,#scroll_x
          row[4].to_s.present? ? row[4].to_s : nil,#scroll_y
          row[5].to_s.present? ? row[5].to_s : nil,#deleted
          row[6].to_s.present? ? row[6].to_s : nil,#created_at
          row[7].to_s.present? ? row[7].to_s : nil,#updated_at
          row[8].to_s.present? ? row[8].to_s : nil,#https_flag
          row[9].to_s.present? ? row[9].to_s : nil#proxy_flag
        )
      end
    end

  end

  # 将下载的live_users.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw20130724
  def self.input_live_users(mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/live_users.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO live_users "
    sql << "(sc_old_id, user_id, live_id, deleted, created_at, updated_at)"
    sql << "VALUES(?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否导入过
      live_user_id = []
      mysql.query("SELECT id FROM live_users where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|a| live_user_id << a}
      next if live_user_id.to_s.present?
      #查找到相应的live_id
      live_id = []
      mysql.query("SELECT id FROM lives where sc_old_id =(#{row[2].to_s}) ORDER BY id DESC LIMIT 1").each {|l| live_id << l}
      #查找到相应的user_id
      user_id = []
      mysql.query("SELECT id FROM users where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|w| user_id << w}
      if live_id.to_s.present? && user_id.to_s.present?
        st.execute(
          row[0].to_s.present? ? row[0].to_s : nil, #sc_old_id
          user_id.to_s.present? ? user_id.to_s : nil, # user_id
          live_id.to_s.present? ? live_id.to_s : nil, #live_id
          row[3].to_s.present? ? row[3].to_s : nil,#deleted
          row[4].to_s.present? ? row[4].to_s : nil,#created_at
          row[5].to_s.present? ? row[5].to_s : nil#updated_at
        )
      end
    end
  end


  # 将下载的view_members.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw20130724
  def self.input_view_members(mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/view_members.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO view_members "
    sql << "(sc_old_id, user_id, live_id, deleted, created_at, updated_at)"
    sql << "VALUES(?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否导入过
      view_member_id = []
      mysql.query("SELECT id FROM view_members where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|a| view_member_id << a}
      next if view_member_id.to_s.present?
      #查找到相应的live_id
      live_id = []
      mysql.query("SELECT id FROM lives where sc_old_id =(#{row[2].to_s}) ORDER BY id DESC LIMIT 1").each {|l| live_id << l}
      #查找到相应的user_id
      user_id = []
      mysql.query("SELECT id FROM users where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|w| user_id << w}
      if live_id.to_s.present? && user_id.to_s.present?
        st.execute(
          row[0].to_s.present? ? row[0].to_s : nil, #sc_old_id
          user_id.to_s.present? ? user_id.to_s : nil, # user_id
          live_id.to_s.present? ? live_id.to_s : nil, #live_id
          row[3].to_s.present? ? row[3].to_s : nil,#deleted
          row[4].to_s.present? ? row[4].to_s : nil,#created_at
          row[5].to_s.present? ? row[5].to_s : nil#updated_at
        )
      end
    end
    
  end


  # 将下载的live_user_hopes.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by phw20130724
  def self.input_live_user_hopes(mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/live_user_hopes.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO live_user_hopes "
    sql << "(sc_old_id, user_id, live_id, deleted, created_at, updated_at,attend_status,course_live_id,mail_flag,force_cancel, leave_flag)"
    sql << "VALUES(?,?,?,?,?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否导入过
      live_user_hope_id = []
      mysql.query("SELECT id FROM live_user_hopes where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|a| live_user_hope_id << a}
      next if live_user_hope_id.to_s.present?
      #查找到相应的live_id
      live_id = []
      mysql.query("SELECT id FROM lives where sc_old_id =(#{row[2].to_s}) ORDER BY id DESC LIMIT 1").each {|l| live_id << l} if row[2].to_s.present?
      #查找到相应的user_id
      user_id = []
      mysql.query("SELECT id FROM users where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|w| user_id << w} if row[1].to_s.present?
      #查找到相应的course_live_id
      course_live_id = []
      mysql.query("SELECT id FROM course_lives where sc_old_id =(#{row[7].to_s}) ORDER BY id DESC LIMIT 1").each {|w| course_live_id << w} if row[7].to_s.present?
      if live_id.to_s.present? && user_id.to_s.present?
        st.execute(
          row[0].to_s.present? ? row[0].to_s : nil, #sc_old_id
          user_id.to_s.present? ? user_id.to_s : nil, # user_id
          live_id.to_s.present? ? live_id.to_s : nil, #live_id
          row[3].to_s.present? ? row[3].to_s : nil,#deleted
          row[4].to_s.present? ? row[4].to_s : nil,#created_at
          row[5].to_s.present? ? row[5].to_s : nil,#updated_at
          row[6].to_s.present? ? row[6].to_s : nil,#attend_status
          course_live_id.to_s.present? ? course_live_id.to_s : nil,#course_live_id
          row[8].to_s.present? ? row[8].to_s : nil,#mail_flag
          row[9].to_s.present? ? row[9].to_s : nil,#force_cancel
          row[10].to_s.present? ? row[10].to_s : nil#leave_flag
        )
      end
    end
  end

  # 将下载的archives.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by wxx20130724
  def self.input_archives(mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/archives.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO archives "
    sql << "(sc_old_id, live_id, name, path, guid, deleted, created_at, updated_at, show_status, teacher_type)"
    sql << "VALUES(?,?,?,?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入
      archive_id = []
      mysql.query("SELECT id FROM archives where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|a| archive_id << a} if row[0].to_s.present?
      archive_id = archive_id.to_s
      next if archive_id.present?
      #查找到live_id
      live_id = []
      mysql.query("SELECT id FROM lives where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|l| live_id << l} if row[1].to_s.present?
      live_id = live_id.to_s
      #execute
      st.execute(
        row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
        live_id.present? ? live_id : nil,#live_id
        row[2].to_s.present? ? row[2].to_s : nil,#name
        row[3].to_s.present? ? row[3].to_s : nil,#path
        row[4].to_s.present? ? row[4].to_s : nil,#guid
        row[5].to_s.present? ? row[5].to_s : nil,#deleted
        row[6].to_s.present? ? row[6].to_s : nil,#created_at
        row[7].to_s.present? ? row[7].to_s : nil,#updated_at
        row[8].to_s.present? ? row[8].to_s : nil,#show_status
        row[9].to_s.present? ? row[9].to_s : nil#teacher_type
      )
    end
  end

  # 将下载的schedules.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by wxx20130724
  def self.input_schedules(mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/schedules.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO schedules "
    sql << "(sc_old_id, from_at, to_at, name, memo, deleted, created_at, updated_at)"
    sql << "VALUES(?,?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入
      schedule_id = []
      mysql.query("SELECT id FROM schedules where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|s| schedule_id << s} if row[0].to_s.present?
      schedule_id = schedule_id.to_s
      next if schedule_id.present?
      #execute
      st.execute(
        row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
        row[1].to_s.present? ? row[1].to_s : nil,#from_at
        row[2].to_s.present? ? row[2].to_s : nil,#to_at
        row[3].to_s.present? ? row[3].to_s : nil,#name
        row[4].to_s.present? ? row[4].to_s : nil,#memo
        row[5].to_s.present? ? row[5].to_s : nil,#deleted
        row[6].to_s.present? ? row[6].to_s : nil,#created_at
        row[7].to_s.present? ? row[7].to_s : nil#updated_at
      )
    end
  end

  # 将下载的schedule_courses.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by wxx20130724
  def self.input_schedule_courses(mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/schedule_courses.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO schedule_courses "
    sql << "(sc_old_id, course_id, schedule_id, deleted, created_at, updated_at)"
    sql << "VALUES(?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入
      schedule_course_id = []
      mysql.query("SELECT id FROM schedule_courses where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|s| schedule_course_id << s} if row[0].to_s.present?
      schedule_course_id = schedule_course_id.to_s
      next if schedule_course_id.present?
      #查找到course_id
      course_id = []
      mysql.query("SELECT id FROM courses where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|c| course_id << c} if row[1].to_s.present?
      course_id = course_id.to_s
      #查找到schedule_id
      schedule_id = []
      mysql.query("SELECT id FROM schedules where sc_old_id =(#{row[2].to_s}) ORDER BY id DESC LIMIT 1").each {|l| schedule_id << l} if row[2].to_s.present?
      schedule_id = schedule_id.to_s
      #execute
      st.execute(
        row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
        course_id.present? ? course_id : nil,#course_id
        schedule_id.present? ? schedule_id.to_s : nil,#schedule_id
        row[3].to_s.present? ? row[3].to_s : nil,#deleted
        row[4].to_s.present? ? row[4].to_s : nil,#created_at
        row[5].to_s.present? ? row[5].to_s : nil#updated_at
      )
    end
  end

  # 将下载的schedule_user_hopes.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by wxx20130724
  def self.input_schedule_user_hopes(mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/schedule_user_hopes.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO schedule_user_hopes "
    sql << "(sc_old_id, schedule_id, user_id, schedule_course_id, attend_status, deleted, created_at, updated_at, force_cancel)"
    sql << "VALUES(?,?,?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入
      schedule_user_hope_id = []
      mysql.query("SELECT id FROM schedule_user_hopes where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|s| schedule_user_hope_id << s} if row[0].to_s.present?
      schedule_user_hope_id = schedule_user_hope_id.to_s
      next if schedule_user_hope_id.present?
      #查找到schedule_id
      schedule_id = []
      mysql.query("SELECT id FROM schedules where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|s| schedule_id << s} if row[1].to_s.present?
      schedule_id = schedule_id.to_s
      #查找到user_id
      user_id = []
      mysql.query("SELECT id FROM users where sc_old_id =(#{row[2].to_s}) ORDER BY id DESC LIMIT 1").each {|u| user_id << u} if row[2].to_s.present?
      user_id = user_id.to_s
      #查找到schedule_course_id
      schedule_course_id = []
      mysql.query("SELECT id FROM schedule_courses where sc_old_id =(#{row[3].to_s}) ORDER BY id DESC LIMIT 1").each {|s| schedule_course_id << s} if row[3].to_s.present?
      schedule_course_id = schedule_course_id.to_s
      #execute
      st.execute(
        row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
        schedule_id.present? ? schedule_id : nil,#schedule_id
        user_id.present? ? user_id.to_s : nil,#user_id
        schedule_course_id.present? ? schedule_course_id.to_s : nil,#schedule_course_id
        row[4].to_s.present? ? row[4].to_s : nil,#attend_status
        row[5].to_s.present? ? row[5].to_s : nil,#deleted
        row[6].to_s.present? ? row[6].to_s : nil,#created_at
        row[7].to_s.present? ? row[7].to_s : nil,#updated_at
        row[8].to_s.present? ? row[8].to_s : nil#force_cancel
      )
    end
  end

  # 将下载的record_servers.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zq20130726
  def self.input_record_servers(mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/record_servers.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO record_servers "
    sql << "(sc_old_id, record_index, record_ip, live_id, created_at, updated_at, start_date, from_at, to_at, deleted)"
    sql << "VALUES(?,?,?,?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入
      record_server_id = []
      mysql.query("SELECT id FROM record_servers where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|s| record_server_id << s} if row[0].to_s.present?
      record_server_id = record_server_id.to_s
      next if record_server_id.present?
      #查找到live_id
      live_id = []
      mysql.query("SELECT id FROM lives where sc_old_id =(#{row[3].to_s}) ORDER BY id DESC LIMIT 1").each {|s| live_id << s} if row[3].to_s.present?
      live_id = live_id.to_s

      #execute
      st.execute(
        row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
        row[1].to_s.present? ? row[1].to_s : nil,#record_index
        row[2].to_s.present? ? row[2].to_s : nil,#record_ip
        live_id.present? ? live_id : nil,        #live_id
        row[4].to_s.present? ? row[4].to_s : nil,#created_at
        row[5].to_s.present? ? row[5].to_s : nil,#updated_at
        row[6].to_s.present? ? row[6].to_s : nil,#start_date
        row[7].to_s.present? ? row[7].to_s : nil,#from_at
        row[8].to_s.present? ? row[8].to_s : nil,#to_at
        row[9].to_s.present? ? row[9].to_s : nil #deleted
      )
    end
  end

  # 将下载的force_converts.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zq20130726
  def self.input_force_converts(mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/force_converts.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO force_converts "
    sql << "(sc_old_id, live_id, url, status, deleted, created_at, updated_at)"
    sql << "VALUES(?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入
      force_convert_id = []
      mysql.query("SELECT id FROM force_converts where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|s| force_convert_id << s} if row[0].to_s.present?
      force_convert_id = force_convert_id.to_s
      next if force_convert_id.present?
      #查找到live_id
      live_id = []
      mysql.query("SELECT id FROM lives where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|s| live_id << s} if row[1].to_s.present?
      live_id = live_id.to_s

      #execute
      st.execute(
        row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
        live_id.present? ? live_id : nil,        #live_id
        row[2].to_s.present? ? row[2].to_s : nil,#url
        row[3].to_s.present? ? row[3].to_s : nil,#status
        row[4].to_s.present? ? row[4].to_s : nil,#deleted
        row[5].to_s.present? ? row[5].to_s : nil,#created_at
        row[6].to_s.present? ? row[6].to_s : nil #updated_at
      )
    end
  end
  

  # 将下载的tv_action_logs.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130726
  def self.input_tv_action_logs(mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/tv_action_logs.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO tv_action_logs "
    sql << "(sc_old_id, live_id, uid, role, mode, sta_end, deleted, created_at, updated_at, content, obj_id)"
    sql << "VALUES(?,?,?,?,?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入
      tv_action_log_id = []
      mysql.query("SELECT id FROM tv_action_logs where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|s| tv_action_log_id << s} if row[0].to_s.present?
      tv_action_log_id = tv_action_log_id.to_s
      next if tv_action_log_id.present?
      #查找到live_id
      live_id = []
      mysql.query("SELECT id FROM lives where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|s| live_id << s} if row[1].to_s.present?
      live_id = live_id.to_s
      #execute
      st.execute(
        row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
        live_id.present? ? live_id : nil,#live_id
        row[2].to_s.present? ? row[2].to_s : nil,#uid
        row[3].to_s.present? ? row[3].to_s : nil,#role
        row[4].to_s.present? ? row[4].to_s : nil,#mode
        row[5].to_s.present? ? row[5].to_s : nil,#sta_end
        row[6].to_s.present? ? row[6].to_s : nil,#deleted
        row[7].to_s.present? ? row[7].to_s : nil,#created_at
        row[8].to_s.present? ? row[8].to_s : nil,#updated_at
        row[9].to_s.present? ? row[9].to_s : nil,#content
        row[10].to_s.present? ? row[10].to_s : nil#obj_id
      )
    end
  end

  # 将下载的tv_chat_logs.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130726
  def self.input_tv_chat_logs(mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/tv_chat_logs.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO tv_chat_logs "
    sql << "(sc_old_id, live_id, uid, role, mode,  content, sta_end, deleted, created_at, updated_at, obj_id)"
    sql << "VALUES(?,?,?,?,?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入
      tv_chat_log_id = []
      mysql.query("SELECT id FROM tv_chat_logs where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|s| tv_chat_log_id << s} if row[0].to_s.present?
      tv_chat_log_id = tv_chat_log_id.to_s
      next if tv_chat_log_id.present?
      #查找到live_id
      live_id = []
      mysql.query("SELECT id FROM lives where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|s| live_id << s} if row[1].to_s.present?
      live_id = live_id.to_s
      #execute
      st.execute(
        row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
        live_id.present? ? live_id : nil,#live_id
        row[2].to_s.present? ? row[2].to_s : nil,#uid
        row[3].to_s.present? ? row[3].to_s : nil,#role
        row[4].to_s.present? ? row[4].to_s : nil,#mode
        row[5].to_s.present? ? row[5].to_s : nil,#content
        row[6].to_s.present? ? row[6].to_s : nil,#sta_end
        row[7].to_s.present? ? row[7].to_s : nil,#deleted
        row[8].to_s.present? ? row[8].to_s : nil,#created_at
        row[9].to_s.present? ? row[9].to_s : nil,#updated_at
        row[10].to_s.present? ? row[10].to_s : nil#obj_id
      )
    end
  end

  # 将下载的tv_file_sends.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130726
  def self. input_tv_file_sends(mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/tv_file_sends.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO tv_file_sends "
    sql << "(sc_old_id, from_id, from_role, to_id, to_role, file_name, file_path, deleted, created_at, updated_at, from_uid,to_uid,mode,live_id,capture_target)"
    sql << "VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入
      tv_file_send_id = []
      mysql.query("SELECT id FROM tv_file_sends where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|s| tv_file_send_id << s} if row[0].to_s.present?
      tv_file_send_id = tv_file_send_id.to_s
      next if tv_file_send_id.present?
      #查找到live_id
      live_id = []
      mysql.query("SELECT id FROM lives where sc_old_id =(#{row[13].to_s}) ORDER BY id DESC LIMIT 1").each {|s| live_id << s} if row[13].to_s.present?
      live_id = live_id.to_s
      #execute
      st.execute(
        row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
        row[1].to_s.present? ? row[1].to_s : nil,#from_id
        row[2].to_s.present? ? row[2].to_s : nil,#from_rode
        row[3].to_s.present? ? row[3].to_s : nil,#to_id
        row[4].to_s.present? ? row[4].to_s : nil,#to_rode
        row[5].to_s.present? ? row[5].to_s : nil,#file_name
        row[6].to_s.present? ? row[6].to_s : nil,#file_path
        row[7].to_s.present? ? row[7].to_s : nil,#deleted
        row[8].to_s.present? ? row[8].to_s : nil,#created_at
        row[9].to_s.present? ? row[9].to_s : nil,#updated_at
        row[10].to_s.present? ? row[10].to_s : nil,#from_uid
        row[11].to_s.present? ? row[11].to_s : nil,#to_uid
        row[12].to_s.present? ? row[12].to_s : nil,#mode
        live_id.present? ? live_id : nil,#live_id
        row[14].to_s.present? ? row[14].to_s : nil#capture_target
      )
    end
  end

  # 将下载的tv_layouts.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130726
  def self.input_tv_layouts(mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/tv_layouts.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO tv_layouts "
    sql << "(sc_old_id, live_id, created_date, title, lecturer_left, lecturer_right, student_left, student_right,videolist_colspan, videolist, videopickup_colspan,videopickup,deleted,created_at, updated_at)"
    sql << "VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入
      tv_layout_id = []
      mysql.query("SELECT id FROM tv_layouts where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|s| tv_layout_id << s} if row[0].to_s.present?
      tv_layout_id = tv_layout_id.to_s
      next if tv_layout_id.present?
      #查找到live_id
      live_id = []
      mysql.query("SELECT id FROM lives where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|s| live_id << s} if row[1].to_s.present?
      live_id = live_id.to_s
      #execute
      st.execute(
        row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
        live_id.present? ? live_id : nil,#live_id
        row[2].to_s.present? ? row[2].to_s : nil,#created_date
        row[3].to_s.present? ? row[3].to_s : nil,#title
        row[4].to_s.present? ? row[4].to_s : nil,#lecturer_left
        row[5].to_s.present? ? row[5].to_s : nil,#lecturer_right
        row[6].to_s.present? ? row[6].to_s : nil,#student_left
        row[7].to_s.present? ? row[7].to_s : nil,#student_right
        row[8].to_s.present? ? row[8].to_s : nil,#videolist_colspan
        row[9].to_s.present? ? row[9].to_s : nil,#videolist
        row[10].to_s.present? ? row[10].to_s : nil,#videopickup_colspan
        row[11].to_s.present? ? row[11].to_s : nil,#videopickup
        row[12].to_s.present? ? row[12].to_s : nil,#deleted
        row[13].to_s.present? ? row[13].to_s : nil,#created_at
        row[14].to_s.present? ? row[14].to_s : nil#updated_at
      )
    end
  end

  # 将下载的tv_status.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130726
  def self.input_tv_status(mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/tv_status.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO tv_status "
    sql << "(sc_old_id, live_id, uid, role, video, mic, volume, whiteboard,read_flag, evicted,deleted,created_at, updated_at,obj_id)"
    sql << "VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入
      tv_status_id = []
      mysql.query("SELECT id FROM tv_status where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|s| tv_status_id << s} if row[0].to_s.present?
      tv_status_id = tv_status_id.to_s
      next if tv_status_id.present?
      #查找到live_id
      live_id = []
      mysql.query("SELECT id FROM lives where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|s| live_id << s} if row[1].to_s.present?
      live_id = live_id.to_s
      #execute
      st.execute(
        row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
        live_id.present? ? live_id : nil,#live_id
        row[2].to_s.present? ? row[2].to_s : nil,#uid
        row[3].to_s.present? ? row[3].to_s : nil,#rode
        row[4].to_s.present? ? row[4].to_s : nil,#video
        row[5].to_s.present? ? row[5].to_s : nil,#mic
        row[6].to_s.present? ? row[6].to_s : nil,#volume
        row[7].to_s.present? ? row[7].to_s : nil,#whitboard
        row[8].to_s.present? ? row[8].to_s : nil,#read_flag
        row[9].to_s.present? ? row[9].to_s : nil,#evicted
        row[10].to_s.present? ? row[10].to_s : nil,#deleted
        row[11].to_s.present? ? row[11].to_s : nil,#created_at
        row[12].to_s.present? ? row[12].to_s : nil,#updated_at
        row[13].to_s.present? ? row[13].to_s : nil #obj_id
      )
    end
  end

  # 将下载的tv_streams.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zj 20130726
  def self.input_tv_streams(mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/tv_streams.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO tv_streams "
    sql << "(sc_old_id, live_id, uid, role, bandwidth, fps, camerawidth, cameraheight,rate, silencelevel,gain,deleted,created_at, updated_at,obj_id)"
    sql << "VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入
      tv_stream_id = []
      mysql.query("SELECT id FROM tv_streams where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|s| tv_stream_id << s} if row[0].to_s.present?
      tv_stream_id = tv_stream_id.to_s
      next if tv_stream_id.present?
      #查找到live_id
      live_id = []
      mysql.query("SELECT id FROM lives where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|s| live_id << s} if row[1].to_s.present?
      live_id = live_id.to_s
      #execute
      st.execute(
        row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
        live_id.present? ? live_id : nil,#live_id
        row[2].to_s.present? ? row[2].to_s : nil,#uid
        row[3].to_s.present? ? row[3].to_s : nil,#rode
        row[4].to_s.present? ? row[4].to_s : nil,#bandwidth
        row[5].to_s.present? ? row[5].to_s : nil,#fps
        row[6].to_s.present? ? row[6].to_s : nil,#camerawidth
        row[7].to_s.present? ? row[7].to_s : nil,#cameraheight
        row[8].to_s.present? ? row[8].to_s : nil,#rate
        row[9].to_s.present? ? row[9].to_s : nil,#silencelevel
        row[10].to_s.present? ? row[10].to_s : nil,#gain
        row[11].to_s.present? ? row[11].to_s : nil,#deleted
        row[12].to_s.present? ? row[12].to_s : nil,#created_at
        row[13].to_s.present? ? row[13].to_s : nil, #updated_at
        row[14].to_s.present? ? row[14].to_s : nil #obj_id
      )
    end
  end

  # 将下载的tv_enquetes.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by wxx20130726
  def self.input_tv_enquetes(mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/tv_enquetes.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO tv_enquetes "
    sql << "(sc_old_id, live_id, title, description, open_flag, create_date, deleted, created_at, updated_at)"#, obj_id 没有赋值
    sql << "VALUES(?,?,?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入
      tv_enquete_id = []
      mysql.query("SELECT id FROM tv_enquetes where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|s| tv_enquete_id << s} if row[0].to_s.present?
      tv_enquete_id = tv_enquete_id.to_s
      next if tv_enquete_id.present?
      #查找到live_id
      live_id = []
      mysql.query("SELECT id FROM lives where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|s| live_id << s} if row[1].to_s.present?
      live_id = live_id.to_s
      #execute
      st.execute(
        row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
        live_id.present? ? live_id : nil,#live_id
        row[2].to_s.present? ? row[2].to_s : nil,#title
        row[3].to_s.present? ? row[3].to_s : nil,#description
        row[4].to_s.present? ? row[4].to_s : nil,#open_flag
        row[5].to_s.present? ? row[5].to_s : nil,#create_date
        row[6].to_s.present? ? row[6].to_s : nil,#deleted
        row[7].to_s.present? ? row[7].to_s : nil,#created_at
        row[8].to_s.present? ? row[8].to_s : nil#updated_at
      )
    end
  end

  # 将下载的tv_questions.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by wxx20130726
  def self.input_tv_questions(mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/tv_questions.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO tv_questions "
    sql << "(sc_old_id, tv_enquete_id, title, description, show_order, deleted, created_at, updated_at)"
    sql << "VALUES(?,?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入
      tv_question_id = []
      mysql.query("SELECT id FROM tv_questions where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|s| tv_question_id << s} if row[0].to_s.present?
      tv_question_id = tv_question_id.to_s
      next if tv_question_id.present?
      #查找到tv_enquete_id
      tv_enquete_id = []
      mysql.query("SELECT id FROM tv_enquetes where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|s| tv_enquete_id << s} if row[1].to_s.present?
      tv_enquete_id = tv_enquete_id.to_s
      #execute
      st.execute(
        row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
        tv_enquete_id.present? ? tv_enquete_id : nil,#tv_enquete_id
        row[2].to_s.present? ? row[2].to_s : nil,#title
        row[3].to_s.present? ? row[3].to_s : nil,#description
        row[4].to_s.present? ? row[4].to_s : nil,#show_order
        row[5].to_s.present? ? row[5].to_s : nil,#deleted
        row[6].to_s.present? ? row[6].to_s : nil,#created_at
        row[7].to_s.present? ? row[7].to_s : nil#updated_at
      )
    end
  end

  # 将下载的tv_enquete_results.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by wxx20130726
  def self.input_tv_enquete_results(mysql, csv_file_path,input_log)
    old_file = csv_file_path + "/tv_enquete_results.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO tv_enquete_results "
    sql << "(sc_old_id, tv_enquete_id, tv_question_id, live_id, memo, deleted, created_at, updated_at, uid)"#row[3] tv_choice_id,row[4] user_id,
    sql << "VALUES(?,?,?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入
      tv_enquete_result_id = []
      mysql.query("SELECT id FROM tv_enquete_results where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|s| tv_enquete_result_id << s} if row[0].to_s.present?
      tv_enquete_result_id = tv_enquete_result_id.to_s
      next if tv_enquete_result_id.present?
      #查找到tv_enquete_id
      tv_enquete_id = []
      mysql.query("SELECT id FROM tv_enquetes where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|s| tv_enquete_id << s} if row[1].to_s.present?
      tv_enquete_id = tv_enquete_id.to_s
      #查找到tv_question_id
      tv_question_id = []
      mysql.query("SELECT id FROM tv_questions where sc_old_id =(#{row[2].to_s}) ORDER BY id DESC LIMIT 1").each {|s| tv_question_id << s} if row[2].to_s.present?
      tv_question_id = tv_question_id.to_s
      #查找到live_id
      live_id = []
      mysql.query("SELECT id FROM lives where sc_old_id =(#{row[5].to_s}) ORDER BY id DESC LIMIT 1").each {|s| live_id << s} if row[5].to_s.present?
      live_id = live_id.to_s
      #execute
      st.execute(
        row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
        tv_enquete_id.present? ? tv_enquete_id : nil,#tv_enquete_id
        tv_question_id.present? ? tv_question_id.to_s : nil,#tv_question_id
        live_id.to_s.present? ? live_id.to_s : nil,#live_id
        row[6].to_s.present? ? row[6].to_s : nil,#memo
        row[7].to_s.present? ? row[7].to_s : nil,#deleted
        row[8].to_s.present? ? row[8].to_s : nil,#created_at
        row[9].to_s.present? ? row[9].to_s : nil,#updated_at
        row[10].to_s.present? ? row[10].to_s : nil#uid
      )
    end
  end

  # 将下载的inquiries.csv文件导入
  #【引数】
  #【返値】
  #【注意】
  #【著作】by wxx20130726
  def self.input_inquiries(mysql, csv_file_path,input_log, school_id)
    old_file = csv_file_path + "/inquiries.csv"
    #prepare
    return unless File.exist?(old_file)
    sql = "INSERT INTO inquiries "
    sql << "(sc_old_id, course_id, user_id, content, answer, flag, deleted, created_at, updated_at,
school_id, tel, company, department, office, first_name,first_name_py, last_name, last_name_py,
sex, zip_code, address1, address2, email, answer_flag)"
    sql << "VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
    st = mysql.prepare(sql)
    row_index = 0
    FasterCSV.foreach(old_file) do |row|
      row_index +=1
      next if row_index == 1
      input_log.info "===========#{row_index}============"
      #判断是否已经导入
      inquiry_id = []
      mysql.query("SELECT id FROM inquiries where sc_old_id =(#{row[0].to_s}) ORDER BY id DESC LIMIT 1").each {|s| inquiry_id << s} if row[0].to_s.present?
      inquiry_id = inquiry_id.to_s
      next if inquiry_id.present?
      #查找到tv_enquete_id
      course_id = []
      mysql.query("SELECT id FROM courses where sc_old_id =(#{row[1].to_s}) ORDER BY id DESC LIMIT 1").each {|s| course_id << s} if row[1].to_s.present?
      course_id = course_id.to_s
      #查找到tv_question_id
      user_id = []
      mysql.query("SELECT id FROM users where sc_old_id =(#{row[2].to_s}) ORDER BY id DESC LIMIT 1").each {|s| user_id << s} if row[2].to_s.present?
      user_id = user_id.to_s
      #execute
      st.execute(
        row[0].to_s.present? ? row[0].to_s : nil,#sc_old_id
        course_id.present? ? course_id : nil,#course_id
        user_id.present? ? user_id : nil,#user_id
        row[3].to_s.present? ? row[3].to_s : nil,#content
        row[4].to_s.present? ? row[4].to_s : nil,#answer
        row[5].to_s.present? ? row[5].to_s : nil,#flag
        row[6].to_s.present? ? row[6].to_s : nil,#deleted
        row[7].to_s.present? ? row[7].to_s : nil,#created_at
        row[8].to_s.present? ? row[8].to_s : nil,#updated_at
        school_id.present? ? school_id : nil,#school_id
        row[10].to_s.present? ? row[10].to_s : nil,#tel
        row[11].to_s.present? ? row[11].to_s : nil,#company
        row[12].to_s.present? ? row[12].to_s : nil,#department
        row[13].to_s.present? ? row[13].to_s : nil,#office
        row[14].to_s.present? ? row[14].to_s : nil,#first_name
        row[15].to_s.present? ? row[15].to_s : nil,#first_name_py
        row[16].to_s.present? ? row[16].to_s : nil,#last_name
        row[17].to_s.present? ? row[17].to_s : nil,#last_name_py
        row[18].to_s.present? ? row[18].to_s : nil,#sex
        row[19].to_s.present? ? row[19].to_s : nil,#zip_code
        row[20].to_s.present? ? row[20].to_s : nil,#address1
        row[21].to_s.present? ? row[21].to_s : nil,#address2
        row[22].to_s.present? ? row[22].to_s : nil,#email
        row[23].to_s.present? ? row[23].to_s : nil#answer_flag
      )
    end
  end

end
