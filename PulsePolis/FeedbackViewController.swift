//
//  FeedbackViewController.swift
//  PulsePolis
//
//  Created by IMAC  on 06.12.15.
//  Copyright © 2015 IMAC . All rights reserved.
//

import UIKit
import RxSwift

class FeedbackViewController: UIViewController, UITextViewDelegate {

    @IBOutlet var txtView: UITextView!
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        if(textView.text == "Текст отзыва   "){
            textView.text = ""
        }
        return true
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n"){
            self.txtView.resignFirstResponder()
            return false
        }
        return true
    }

    func textViewDidEndEditing(textView: UITextView) {
        if(textView.text.characters.count == 0){
            self.txtView.text = "Текст отзыва   "
        }
    }
    
    @IBAction func feedback(sender: AnyObject) {
        if (self.txtView.text.characters.count > 0 && self.txtView.text != "Текст отзыва   "){
            self.sendFeedback(self.txtView.text)
        } else {
            self.showAlert("Невозможно отправить отзыв", msg: "Введите текст отзыва")
        }
    }
    
    //MARK: IBActions
    @IBAction func backBtnPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func sendFeedback(text: String){
        let networkClient = NetworkClient()
        networkClient.feedback(text).observeOn(MainScheduler.instance)
        .subscribe(onNext: { (networkResponse) -> Void in
                if(networkResponse.status == Status.Success){
                    self.showAlertWithCloseController("", msg: "Спасибо! Ваш отзыв принят")
                } else {
                    self.showAlert("", msg: "Ошибка при отправке отзыва")
            }
            }, onError: { (err) -> Void in
                self.showAlert("", msg: "Ошибка при отправке отзыва")
            }, onCompleted: { () -> Void in
                
            }) { () -> Void in
                
        }.addDisposableTo(self.disposeBag)
    }
    
    //MARK: Alerts
    func showAlert(title: String, msg: String){
        let alert = UIAlertController(title: title,
            message: msg,
            preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAction = UIAlertAction(title: "OK",
            style: .Cancel, handler: nil)
        
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func showAlertWithCloseController(title: String, msg: String){
        let alert = UIAlertController(title: title,
            message: msg,
            preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAction = UIAlertAction(title: "OK",
            style: .Cancel, handler: { (action) -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
            })
    
    
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
