# THIS FILE IS AUTO-GENERATED. DO NOT MODIFY!!

# Copyright 2020-2023 Tauri Programme within The Commons Conservancy
# SPDX-License-Identifier: Apache-2.0
# SPDX-License-Identifier: MIT

-keep class baomihua.eu.org.* {
  native <methods>;
}

-keep class baomihua.eu.org.WryActivity {
  public <init>(...);

  void setWebView(baomihua.eu.org.RustWebView);
  java.lang.Class getAppClass(...);
  int getId();
  java.lang.String getVersion();
  int startActivity(...);
}

-keep class baomihua.eu.org.Ipc {
  public <init>(...);

  @android.webkit.JavascriptInterface public <methods>;
}

-keep class baomihua.eu.org.RustWebView {
  public <init>(...);

  void loadUrlMainThread(...);
  void loadHTMLMainThread(...);
  void evalScript(...);
}

-keep class baomihua.eu.org.RustWebChromeClient,baomihua.eu.org.RustWebViewClient {
  public <init>(...);
}
