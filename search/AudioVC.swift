import UIKit

class AudioVC: UIViewController{
    @IBOutlet var backgroung: UIImageView!
    @IBOutlet var mainImageView: UIImageView!
    @IBOutlet var songTitle: UILabel!

    var image = UIImage()
    var mainSongTitle = String()

    override func viewDidLoad() {
        songTitle.text = mainSongTitle
        backgroung.image = image
        mainImageView.image = image
    }
}
