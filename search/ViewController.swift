import UIKit
import Alamofire

struct post {
    let mainImage: UIImage!
    let name: String!
}

class TableViewController: UITableViewController, UITextFieldDelegate {
    
    var posts = [post]()
    
    let tokenURL = "https://accounts.spotify.com/api/token"
    
    let basicHeader: HTTPHeaders = ["Authorization" : "Basic Y2I2ZmM2Mj...NzA2Mzk="]

    let parameters: Parameters = ["grant_type" : "client_credentials"]
    
    typealias JSONStandard = [String : AnyObject]
    
    @IBAction func search(_ sender: UITextField) {
        if sender.text!.isEmpty {
            return
        }
        else{
            var searchKey: String = sender.text as! String
            if let key = searchKey.range(of: " "){
                searchKey.replaceSubrange(key, with: "%20")
            }
            
            let searchURL = "https://api.spotify.com/v1/search?q=\(searchKey)&type=album&limit=20"
            
            posts.removeAll()
            callAlamo(url: searchURL)
            
        }
    }
    
    func getAccessToken(Token: Data) -> HTTPHeaders{
        var tokenJSON = try! JSONSerialization.jsonObject(with: Token, options: .mutableContainers) as! JSONStandard
        let token = tokenJSON["access_token"] as! String
        let access_token: HTTPHeaders = ["Authorization" : "Bearer \(token)"]
        
        return access_token
    }
    
    func callAlamo(url: String) {
        Alamofire.request(self.tokenURL, method: .post, parameters: parameters, headers: basicHeader).responseJSON(completionHandler: {
            tokens in
            Alamofire.request(url, headers: self.getAccessToken(Token: tokens.data!)).responseJSON(completionHandler: {
                response in
                self.parseData(JSONData: response.data!)
            })
        })
    }
    
    func parseData(JSONData: Data){
        do{
            var searchJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! JSONStandard
            
            if let albums = searchJSON["albums"] as? JSONStandard {
                if let items = albums["items"] {
                    for i in 0..<items.count{
                        let item = (items as! NSArray)[i] as! JSONStandard
                        // album title
                        let name = item["name"] as! String
                        // album artwork
                        let image = (item["images"] as! NSArray)[0] as! NSDictionary
                        let imageURL = URL(string: image["url"] as! String)
                        let imageData = NSData(contentsOf: imageURL!)
                        let mainImage = UIImage(data: imageData! as Data)
                        
                        posts.append(post.init(mainImage: mainImage, name: name))
                        
                        self.tableView.reloadData()
                    }
                }
            }
        }catch{
            print(error)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        let mainImageView = cell?.viewWithTag(1) as! UIImageView
        mainImageView.image = posts[indexPath.row].mainImage
        
        let mainLabel = cell?.viewWithTag(2) as! UILabel
        mainLabel.text = posts[indexPath.row].name
        
        return cell!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = self.tableView.indexPathForSelectedRow?.row

        let vc = segue.destination as! AudioVC

        vc.image = posts[indexPath!].mainImage
        vc.mainSongTitle = posts[indexPath!].name
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

