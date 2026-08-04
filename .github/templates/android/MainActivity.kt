package {{android-identifier}}

import android.os.Build
import android.os.Bundle
import android.view.ViewGroup
import android.webkit.WebView
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat

class MainActivity : TauriActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    // 传统模式：内容自动避开状态栏/导航条（WebView 不延伸到系统栏区域）。
    // 注意：不能调用 enableEdgeToEdge() —— Chromium WebView 会忽略 View padding，
    // edge-to-edge 下页面内容仍会占满全屏导致顶部导航与状态栏重叠。
    // Android 15 强制 edge-to-edge 时会忽略此设置，由 onWebViewCreate 的 margin 兜底。
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
      window.setDecorFitsSystemWindows(true)
    }
    super.onCreate(savedInstanceState)
  }

  /**
   * 安全区兜底：Android 15（强制 edge-to-edge）等场景下，通过调整 WebView 布局
   * margin 让内容避开状态栏（刘海屏/挖孔屏）与手势导航条。
   * 使用 margin 而非 padding —— 现代 Chromium WebView 忽略 View padding，
   * 内容仍会渲染到 padding 区域（padding 方案无效）。
   */
  override fun onWebViewCreate(webView: WebView) {
    super.onWebViewCreate(webView)
    ViewCompat.setOnApplyWindowInsetsListener(webView) { v, insets ->
      val bars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
      val lp = v.layoutParams
      if (lp is ViewGroup.MarginLayoutParams) {
        lp.topMargin = bars.top
        lp.bottomMargin = bars.bottom
        v.layoutParams = lp
      }
      insets
    }
    // listener 注册可能晚于首次 insets 分派：主动请求覆盖各时机
    ViewCompat.requestApplyInsets(webView)
    webView.post { ViewCompat.requestApplyInsets(webView) }
    webView.postDelayed({ ViewCompat.requestApplyInsets(webView) }, 300)
  }
}
