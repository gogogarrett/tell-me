class AppDelegate

  def applicationDidFinishLaunching(notification)
    @current_app = "Student"
    build_status_menu
    set_interval_timer
  end

  def build_status_menu
    @statusBar = NSStatusBar.systemStatusBar
    @item = @statusBar.statusItemWithLength(NSVariableStatusItemLength)

    @item.setTitle('Loading..')
    # image = NSImage.imageNamed "temp"
    # image.setSize(NSMakeSize(16, 16))

    @item.retain
    # @item.setImage image
    @item.setHighlightMode(true)
    @item.setMenu(menu)
  end

  def menu
    @menu = NSMenu.new
    @menu.title = "Tell Me"

    student_app = NSMenuItem.new
    student_app.title = "Student App"
    student_app.setRepresentedObject(3600)
    student_app.action = "set_app:"

    teacher_app = NSMenuItem.new
    teacher_app.title = "Teacher App"
    teacher_app.setRepresentedObject(7200)
    teacher_app.action = "set_app:"

    @app_menu = NSMenu.new
    @app_menu.addItem student_app
    @app_menu.addItem teacher_app

    main = NSMenuItem.new
    main.title = "Change App.."
    main.setSubmenu @app_menu

    quit = NSMenuItem.new
    quit.title = "Quit"
    quit.action = "terminate:"

    @menu.addItem main
    @menu.addItem NSMenuItem.separatorItem
    @menu.addItem quit

    @menu
  end

  def set_app(sender)
    title = sender.title ? sender.title.split(" ")[0] : "No app"
    @current_app = title
    change_item_info("Loading")
  end

  def set_interval_timer
    interval = 5
    EM.cancel_timer(@interval_timer)

    @interval_timer = EM.add_periodic_timer interval do
      get_user_stats
    end
  end

  def get_user_stats
    client.get("data/realtime?ids=#{app_api_key}&metrics=rt%3AactiveUsers") do |result|
      if result.success?
        currentUserStat = result.object['totalsForAllResults']['rt:activeUsers']
        change_item_info(currentUserStat)
      elsif result.failure?
        p result.error.localizedDescription
      end
    end
  end

  def client
    url = "https://www.googleapis.com/analytics/v3/"
    client = AFMotion::SessionClient.build(url) do
      header "Accept", "application/json"
      header "Authorization", "Bearer ya29.mQCFtlSbjtQXjsFWNMUpc4eEPzopDeMjFHPRFPZH9BxTlG-FmrKUZMyf"
      response_serializer :json
    end
  end

  def change_item_info(number)
    @item.setTitle("#{@current_app}: #{number}")
  end

  def app_api_key
    {
      "student" => "ga%3A89996022",
      "teacher" => "ga%3A89995039",
    }[@current_app.downcase]
  end
end
