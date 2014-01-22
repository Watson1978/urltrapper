class AppDelegate
  def applicationDidFinishLaunching(notification)
    buildMenu
    buildWindow
    setEventHandler
  end

  def buildWindow
    width  = 480
    height = 360
    @mainWindow = NSWindow.alloc.initWithContentRect([[240, 180], [width, height]],
      styleMask: NSTitledWindowMask|NSClosableWindowMask|NSMiniaturizableWindowMask|NSResizableWindowMask,
      backing: NSBackingStoreBuffered,
      defer: false)
    @mainWindow.title = NSBundle.mainBundle.infoDictionary['CFBundleName']
    @mainWindow.orderFrontRegardless

    margin = 10
    text_height = height/2
    @text = NSTextField.alloc.initWithFrame([[margin, height-text_height], [width-margin*2, text_height-margin]])
    @text.autoresizingMask = NSViewMinXMargin|NSViewMinYMargin|NSViewWidthSizable|NSViewHeightSizable
    @mainWindow.contentView.addSubview(@text)

    buildButtons(width, height, margin)
  end

  BUTTONS = [
    [
      'Set Default Browser',
      :setDefaultBrowser,
    ],
    [
      'Open Firefox',
      :openFirefox,
    ],
    [
      'Open Google Chrome',
      :openChrome,
    ],
    [
      'Open Google Chrome (incognito)',
      :openChromeIncognito,
    ],
    [
      'Open Safari',
      :openSafari,
    ],
  ]

  def buildButtons(width, height, margin)
    BUTTONS.reverse_each.with_index do |(title, action), idx|
      button = NSButton.alloc.initWithFrame([[margin, margin+30*idx], [width-margin*2, 32]])
      button.title = title
      button.action = action
      button.target = self
      button.bezelStyle = NSRoundedBezelStyle
      button.autoresizingMask = NSViewMinXMargin|NSViewMaxYMargin|NSViewWidthSizable
      @mainWindow.contentView.addSubview(button)
    end
  end

  def setEventHandler
    NSAppleEventManager.sharedAppleEventManager.setEventHandler(
      self,
      andSelector: :'handleGetURLEvent:withReplyEvent:',
      forEventClass: KInternetEventClass,
      andEventID: KAEGetURL)
  end

  def setDefaultBrowser
    bundle_id = NSBundle.mainBundle.bundleIdentifier
    LSSetDefaultHandlerForURLScheme('http', bundle_id)
    LSSetDefaultHandlerForURLScheme('https', bundle_id)
    LSSetDefaultHandlerForURLScheme('ftp', bundle_id)
    #LSSetDefaultRoleHandlerForContentType('public.html', KLSRolesAll, bundle_id)
  end

  def handleGetURLEvent(event, withReplyEvent: replyEvent)
    keyDirectObject = '----'.unpack('L')[0]
    urlStr = event.paramDescriptorForKeyword(keyDirectObject).stringValue
    @text.stringValue = urlStr

    pid = Process.spawn("osascript", "-e", <<-SCRIPT)
tell Application "#{NSBundle.mainBundle.infoDictionary['CFBundleName']}"
  activate
end tell
    SCRIPT
    Process.detach(pid)
  end

  def openFirefox
    pid = Process.spawn("open", "-b", "org.mozilla.firefox", @text.stringValue)
    Process.detach(pid)
  end

  def openChrome
    pid = Process.spawn("open", "-b", "com.google.Chrome", @text.stringValue)
    Process.detach(pid)
  end

  def openChromeIncognito
    pid = Process.spawn("open", "-b", "com.google.Chrome", @text.stringValue, "--args", "-incognito")
    Process.detach(pid)
  end

  def openSafari
    pid = Process.spawn("open", "-b", "com.apple.Safari", @text.stringValue)
    Process.detach(pid)
  end
end
