module.exports = {
  base: "/hippo/",
  title: "Hippo",
  description: "Kubernetes deployment toolkit",
  markdown: {
    lineNumbers: true
  },
  themeConfig: {
    sidebarDepth: 0,
    displayAllHeaders: false,
    nav: [
      { text: "Documentation", link: "/" },
      { text: "Code", link: "https://github.com/adamcooke/hippo/" },
      { text: "Slack", link: "https://slack.adam.ac" }
    ],
    sidebar: [
      {
        title: "Getting Started",
        collapsable: false,
        sidebarDepth: 0,
        children: ["/", "/install"]
      },
      {
        title: "Using Hippo",
        collapsable: false,
        sidebarDepth: 0,
        children: [
          "/using/",
          "/using/creating-a-stage",
          "/using/configuration",
          "/using/preparing",
          "/using/installing-the-application",
          "/using/status",
          "/using/deploying-updates",
          "/using/console-and-commands"
        ]
      },
      {
        title: "Writing manifests",
        collapsable: false,
        sidebarDepth: 0,
        children: ["/manifests/"]
      }
    ]
  }
};
