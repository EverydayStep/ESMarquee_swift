//
//  ViewController.swift
//  ESMarquee_swift
//
//  Created by codeLocker on 2020/5/13.
//  Copyright © 2020 codeLocker. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        let text: String = "1234567890fnafnsdjkn"

        let view = ESMarquee(frame: CGRect.zero, scrollDirection: .down)
        view.backgroundColor = UIColor.red
        view.text = text
        view.click = {
//            print("111")
            view.pause()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                view.resume()
            }
        }
//        view.text = text
//        view.text = "12345n"
//        view.font = UIFont.systemFont(ofSize: 50)
        view.textColor = UIColor.white
        
        self.view.addSubview(view)
        view.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.height.equalTo(300)
            make.width.equalTo(40)
        }
        
        // Do any additional setup after loading the view.
    }


}

