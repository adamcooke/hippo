(window.webpackJsonp=window.webpackJsonp||[]).push([[13],{210:function(s,e,t){"use strict";t.r(e);var n=t(28),a=Object(n.a)({},(function(){var s=this,e=s.$createElement,t=s._self._c||e;return t("ContentSlotsDistributor",{attrs:{"slot-key":s.$parent.slotKey}},[t("h1",{attrs:{id:"installing-the-application"}},[t("a",{staticClass:"header-anchor",attrs:{href:"#installing-the-application"}},[s._v("#")]),s._v(" Installing the application")]),s._v(" "),t("p",[s._v("Once prepared, the application can be installed to the cluster. If everything has gone smoothly and the application's manifest has been configured correctly, this should be a simple operation.")]),s._v(" "),t("div",{staticClass:"custom-block warning"},[t("p",{staticClass:"custom-block-title"},[s._v("NOTE ABOUT INSTALL")]),s._v(" "),t("p",[s._v("You should only use the "),t("code",[s._v("install")]),s._v(" command the first time you install the application. To update the application in the future you should switch to using "),t("code",[s._v("deploy")]),s._v(".")])]),s._v(" "),t("h2",{attrs:{id:"what-happen-s-during-an-install"}},[t("a",{staticClass:"header-anchor",attrs:{href:"#what-happen-s-during-an-install"}},[s._v("#")]),s._v(" What happen's during an install?")]),s._v(" "),t("ul",[t("li",[t("p",[s._v("Any configuration files will be repushed to Kubernetes.")])]),s._v(" "),t("li",[t("p",[s._v("Any "),t("code",[s._v("install")]),s._v(" jobs will be executed. Hippo will wait for them to complete successfully before continuing with the installation. If they fail or time out, the installation will be stopped. These jobs usually install database schemas or generally prepare any storage requirements.")])]),s._v(" "),t("li",[t("p",[s._v("The application deployments (or stateful/daemon sets) will be applied to Kubernetes which will then begin to automatically start pods as needed.")])]),s._v(" "),t("li",[t("p",[s._v("Hippo will then wait for all deployments to be rolled out successfully.")])]),s._v(" "),t("li",[t("p",[s._v("When successful, all services (and ingresses and network policies) will be applied.")])])]),s._v(" "),t("h2",{attrs:{id:"running-the-installation"}},[t("a",{staticClass:"header-anchor",attrs:{href:"#running-the-installation"}},[s._v("#")]),s._v(" Running the installation")]),s._v(" "),t("p",[s._v("Just run the "),t("code",[s._v("hippo [stage-name] install")]),s._v(" command:")]),s._v(" "),t("div",{staticClass:"language-bash line-numbers-mode"},[t("pre",{pre:!0,attrs:{class:"language-bash"}},[t("code",[s._v("hippo "),t("span",{pre:!0,attrs:{class:"token punctuation"}},[s._v("[")]),s._v("stage-name"),t("span",{pre:!0,attrs:{class:"token punctuation"}},[s._v("]")]),s._v(" "),t("span",{pre:!0,attrs:{class:"token function"}},[s._v("install")]),s._v("\n"),t("span",{pre:!0,attrs:{class:"token comment"}},[s._v("# Updating manifest from https://github.com/postalhq/k8s-hippo... done")]),s._v("\n"),t("span",{pre:!0,attrs:{class:"token comment"}},[s._v("# Image for main exists at adamcooke/postal:docker")]),s._v("\n"),t("span",{pre:!0,attrs:{class:"token comment"}},[s._v("# Applying 1 namespace object")]),s._v("\n"),t("span",{pre:!0,attrs:{class:"token comment"}},[s._v("# ====> namespace/postal-demo unchanged")]),s._v("\n"),t("span",{pre:!0,attrs:{class:"token comment"}},[s._v("# Downloading secret encryiption key... done")]),s._v("\n"),t("span",{pre:!0,attrs:{class:"token comment"}},[s._v("# Applying 1 configuration object")]),s._v("\n"),t("span",{pre:!0,attrs:{class:"token comment"}},[s._v("# ====> secret/postal-config unchanged")]),s._v("\n"),t("span",{pre:!0,attrs:{class:"token comment"}},[s._v("# Running install jobs")]),s._v("\n"),t("span",{pre:!0,attrs:{class:"token comment"}},[s._v("# Applying 1 deploy job object")]),s._v("\n"),t("span",{pre:!0,attrs:{class:"token comment"}},[s._v("# ====> job.batch/initialize created")]),s._v("\n"),t("span",{pre:!0,attrs:{class:"token comment"}},[s._v("# All jobs completed successfully")]),s._v("\n"),t("span",{pre:!0,attrs:{class:"token comment"}},[s._v("# You can review the logs for these by running the commands below")]),s._v("\n"),t("span",{pre:!0,attrs:{class:"token comment"}},[s._v("#")]),s._v("\n"),t("span",{pre:!0,attrs:{class:"token comment"}},[s._v("#   ✅  hippo staging kubectl -- logs job/initialize")]),s._v("\n"),t("span",{pre:!0,attrs:{class:"token comment"}},[s._v("#")]),s._v("\n"),t("span",{pre:!0,attrs:{class:"token comment"}},[s._v("# Using deployment ID: 7af69667d5cd")]),s._v("\n"),t("span",{pre:!0,attrs:{class:"token comment"}},[s._v("# Applying 5 deployment objects")]),s._v("\n"),t("span",{pre:!0,attrs:{class:"token comment"}},[s._v("# ====> deployment.apps/cron created")]),s._v("\n"),t("span",{pre:!0,attrs:{class:"token comment"}},[s._v("# ====> deployment.apps/requeuer created")]),s._v("\n"),t("span",{pre:!0,attrs:{class:"token comment"}},[s._v("# ====> deployment.apps/worker created")]),s._v("\n"),t("span",{pre:!0,attrs:{class:"token comment"}},[s._v("# ====> deployment.apps/smtp created")]),s._v("\n"),t("span",{pre:!0,attrs:{class:"token comment"}},[s._v("# ====> deployment.apps/web created")]),s._v("\n"),t("span",{pre:!0,attrs:{class:"token comment"}},[s._v("# Waiting for all deployments to roll out...")]),s._v("\n"),t("span",{pre:!0,attrs:{class:"token comment"}},[s._v("# Waiting for 3 deployments (smtp, web, worker)")]),s._v("\n"),t("span",{pre:!0,attrs:{class:"token comment"}},[s._v("# Waiting for 2 deployments (smtp, web)")]),s._v("\n"),t("span",{pre:!0,attrs:{class:"token comment"}},[s._v("# Waiting for 1 deployment (web)")]),s._v("\n"),t("span",{pre:!0,attrs:{class:"token comment"}},[s._v("# All 5 deployments all rolled out successfully")]),s._v("\n"),t("span",{pre:!0,attrs:{class:"token comment"}},[s._v("# Applying 9 service objects")]),s._v("\n"),t("span",{pre:!0,attrs:{class:"token comment"}},[s._v("# ====> ingress.networking.k8s.io/postal-web created")]),s._v("\n"),t("span",{pre:!0,attrs:{class:"token comment"}},[s._v("# ====> service/web created")]),s._v("\n"),t("span",{pre:!0,attrs:{class:"token comment"}},[s._v("# ====> networkpolicy.networking.k8s.io/default-block-policy created")]),s._v("\n"),t("span",{pre:!0,attrs:{class:"token comment"}},[s._v("# ====> networkpolicy.networking.k8s.io/allow-namespace-traffic created")]),s._v("\n"),t("span",{pre:!0,attrs:{class:"token comment"}},[s._v("# ====> networkpolicy.networking.k8s.io/allow-ingress-to-web created")]),s._v("\n"),t("span",{pre:!0,attrs:{class:"token comment"}},[s._v("# ====> networkpolicy.networking.k8s.io/allow-ingress-to-smtp created")]),s._v("\n"),t("span",{pre:!0,attrs:{class:"token comment"}},[s._v("# ====> networkpolicy.networking.k8s.io/allow-prometheus-traffic created")]),s._v("\n"),t("span",{pre:!0,attrs:{class:"token comment"}},[s._v("# ====> networkpolicy.networking.k8s.io/allow-cert-manager-traffic created")]),s._v("\n"),t("span",{pre:!0,attrs:{class:"token comment"}},[s._v("# ====> service/smtp created")]),s._v("\n")])]),s._v(" "),t("div",{staticClass:"line-numbers-wrapper"},[t("span",{staticClass:"line-number"},[s._v("1")]),t("br"),t("span",{staticClass:"line-number"},[s._v("2")]),t("br"),t("span",{staticClass:"line-number"},[s._v("3")]),t("br"),t("span",{staticClass:"line-number"},[s._v("4")]),t("br"),t("span",{staticClass:"line-number"},[s._v("5")]),t("br"),t("span",{staticClass:"line-number"},[s._v("6")]),t("br"),t("span",{staticClass:"line-number"},[s._v("7")]),t("br"),t("span",{staticClass:"line-number"},[s._v("8")]),t("br"),t("span",{staticClass:"line-number"},[s._v("9")]),t("br"),t("span",{staticClass:"line-number"},[s._v("10")]),t("br"),t("span",{staticClass:"line-number"},[s._v("11")]),t("br"),t("span",{staticClass:"line-number"},[s._v("12")]),t("br"),t("span",{staticClass:"line-number"},[s._v("13")]),t("br"),t("span",{staticClass:"line-number"},[s._v("14")]),t("br"),t("span",{staticClass:"line-number"},[s._v("15")]),t("br"),t("span",{staticClass:"line-number"},[s._v("16")]),t("br"),t("span",{staticClass:"line-number"},[s._v("17")]),t("br"),t("span",{staticClass:"line-number"},[s._v("18")]),t("br"),t("span",{staticClass:"line-number"},[s._v("19")]),t("br"),t("span",{staticClass:"line-number"},[s._v("20")]),t("br"),t("span",{staticClass:"line-number"},[s._v("21")]),t("br"),t("span",{staticClass:"line-number"},[s._v("22")]),t("br"),t("span",{staticClass:"line-number"},[s._v("23")]),t("br"),t("span",{staticClass:"line-number"},[s._v("24")]),t("br"),t("span",{staticClass:"line-number"},[s._v("25")]),t("br"),t("span",{staticClass:"line-number"},[s._v("26")]),t("br"),t("span",{staticClass:"line-number"},[s._v("27")]),t("br"),t("span",{staticClass:"line-number"},[s._v("28")]),t("br"),t("span",{staticClass:"line-number"},[s._v("29")]),t("br"),t("span",{staticClass:"line-number"},[s._v("30")]),t("br"),t("span",{staticClass:"line-number"},[s._v("31")]),t("br"),t("span",{staticClass:"line-number"},[s._v("32")]),t("br"),t("span",{staticClass:"line-number"},[s._v("33")]),t("br"),t("span",{staticClass:"line-number"},[s._v("34")]),t("br"),t("span",{staticClass:"line-number"},[s._v("35")]),t("br"),t("span",{staticClass:"line-number"},[s._v("36")]),t("br"),t("span",{staticClass:"line-number"},[s._v("37")]),t("br"),t("span",{staticClass:"line-number"},[s._v("38")]),t("br")])]),t("p",[s._v("The output you receive should look similar to above however it may be different if the jobs fail or the deployments do not roll out successfully. The output in these cases will show you the commands you can run to investigate the cause for these issues further.")])])}),[],!1,null,null,null);e.default=a.exports}}]);