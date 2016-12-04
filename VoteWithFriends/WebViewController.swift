import UIKit

class WebViewController: UIViewController,UIWebViewDelegate {

    //@IBOutlet weak var navigationTitle: UINavigationBar!
    //@IBOutlet weak var navigationTitle: UINavigationItem!
    //@IBOutlet weak var navigationTitle: UINavigationBar!
    @IBOutlet weak var navigationTitle: UINavigationBar!

    @IBOutlet weak var webView: UIWebView!
    
    var toPass:String!
    var toPass2:String!
    var toPass3:String!
    
    //var url:NSURL!
    //var url2:NSURL!
    
    var navTitle:String!
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // self.webView.loadRequest(NSURLRequest(URL: NSBundle.mainBundle().URLForResource("index", withExtension: "html", subdirectory: "faq")!))
        // webView?.loadRequest(NSURLRequest(URL: NSURL(string: "www.google.com")!))
        print(toPass)
        
        // REFERENCE:  https://www.facebook.com/search/str/David%2BKim/users-named/me/friends/intersect
        

        //var url2 : NSString = "https://www.facebook.com/search/str/" + toPass2 + "%2B" + toPass3 + "/users-named/me/friends/intersect"
        
        var url2 : NSString = "https://www.facebook.com/search/str/" + toPass + "/users-named/me/friends/intersect"
        print(url2)
        var urlStr : NSString = url2.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        var searchURL : NSURL = NSURL(string: urlStr as String)!
        print(searchURL)
        let searchURL2: String = searchURL.absoluteString!

        //webView.loadRequest(NSURLRequest(URL: NSURL(string: searchURL2)!))
        webView?.loadRequest(NSURLRequest(URL: NSURL(string: searchURL2)!))
    }
    
    @IBAction func backAction(sender: AnyObject) {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    @IBAction func forwardAction(sender: AnyObject) {
        if webView.canGoForward {
            webView.goForward()
        }
    }
    
    @IBAction func refreshAction(sender: AnyObject) {
        webView.reload()
    }

    @IBAction func stopAction(sender: AnyObject) {
        webView.stopLoading()
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true        
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
       //navigationTitle.title = webView.stringByEvaluatingJavaScriptFromString("document.title")
        //navigationTitle.title = "Facebook Targets"
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }   
}
