
<#macro font>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Nunito+Sans:ital,wght@0,200;0,300;0,400;0,600;0,700;0,800;0,900;1,200;1,300;1,400;1,600;1,700;1,800;1,900&display=swap" rel="stylesheet">
</#macro>

<#macro header>
  <div id="kc-header" class="${properties.kcHeaderClass!}">
      <div id="kc-header-wrapper"
            class="${properties.kcHeaderWrapperClass!}">${kcSanitize(msg("loginTitleHtml",(realm.displayNameHtml!'')))?no_esc}</div>
  </div>
</#macro>

<#macro footer>
  <div class="${properties.kcFooterClass!}">
  <#--  Footer  -->
  Footer
  </div>
</#macro>

<#macro feature>
  <div class="${properties.kcFeatureSectionClass!}">
  <#--  Features  -->
  </div>
</#macro>

<#macro loginSectionHeader>
  <div class="${properties.kcLoginSectionHeaderClass!}">
    <#--  Logo  -->
    <div class="${properties.kcLogoClass!}"></div>
    <div class="${properties.kcRealmInfoClass!}">${kcSanitize(msg("loginTitleHtml",(realm.displayNameHtml!'')))?no_esc}</div>
  </div>
</#macro>

<#macro loginSectionFooter>
  <div class="${properties.kcLoginSectionFooterClass!}">
    <div>By signing in, you agree to our <a href="https://noroutine.me/terms" target="_blank">terms of service</a>.</div>
    <hr />
    <div>
      <p>Operated by <a href="https://noroutine.me/" target="_blank">noroutine</a></p>
    </div>
  </div>
</#macro>
