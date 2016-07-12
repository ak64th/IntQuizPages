module.exports =
  layout:
    activate: ->
      self = this
      self.fix()
      $(window, ".wrapper").resize ->
        self.fix()
    fix: ->
      neg = $(".main-header").outerHeight() + $(".main-footer").outerHeight()
      window_height = $(window).height()
      sidebar_height = $(".sidebar").height()
      if window_height >= sidebar_height
        $(".content-wrapper").css "min-height", window_height - neg
      else
        $(".content-wrapper").css "min-height", sidebar_height
  pushMenu:
    activate:  ->
      $('#collapseToggle').on "click", (e) ->
        e.preventDefault()
        if $(window).width() > (768 - 1)
          if $("body").hasClass("sidebar-collapse")
            $("body").removeClass("sidebar-collapse")
          else
            $("body").addClass("sidebar-collapse")
        else
          if $("body").hasClass("sidebar-open")
            $("body").removeClass("sidebar-open").removeClass("sidebar-collapse")
          else
            $("body").addClass("sidebar-open")
      $(".content-wrapper").click ->
        $("body").removeClass "sidebar-open"  if $(window).width() <= (768 - 1) and $("body").hasClass("sidebar-open")
  tree: ->
    self = this
    animationSpeed = 500
    $('body').on "click", ".sidebar li a", (e) ->
      $this = $(this)
      checkElement = $this.next()
      if (checkElement.is(".treeview-menu")) and (checkElement.is(":visible"))
        checkElement.slideUp animationSpeed, ->
          checkElement.removeClass "menu-open"
        self.layout.fix();
        checkElement.parent("li").removeClass "active"
      else if checkElement.is(".treeview-menu")
        parent = $this.parents("ul").first()
        ul = parent.find("ul:visible").slideUp(animationSpeed)
        ul.removeClass "menu-open"
        parent_li = $this.parent("li")
        checkElement.slideDown animationSpeed, ->
          checkElement.addClass "menu-open"
          parent.find("li.active").removeClass "active"
          parent_li.addClass "active"
          self.layout.fix()
      e.preventDefault()  if checkElement.is(".treeview-menu")
