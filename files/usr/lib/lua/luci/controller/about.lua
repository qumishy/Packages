module("luci.controller.about", package.seeall)

function index()
    entry({"admin", "about"}, call("action_about"), _("About Us"), 90).leaf = true
end

function action_about()
    luci.template.render("about_page")
end
