//
//  ViewController.swift
//  Tutorial2
//
//  Created by Karthika Rajendran on 2022-06-30.
//

import UIKit
import AVFoundation

extension String {

       func stringByAppendingPathComponent(path: String) -> String {

             let nsSt = self as NSString
             return nsSt.appendingPathComponent(path)
       }
}

class ViewController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate{

var audioPlayer : AVAudioPlayer!
var audioRecorder : AVAudioRecorder!

@IBOutlet var recordButton : UIButton!
@IBOutlet var playButton : UIButton!
@IBOutlet var stopButton : UIButton!

override func viewDidLoad() {
    super.viewDidLoad()

    self.recordButton.isEnabled = true
    self.playButton.isEnabled = false
    self.stopButton.isEnabled = false
}

override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
}

//MARK: UIButton action methods

@IBAction func playButtonClicked(sender : AnyObject){

//    let dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
    let dispatchQueue = DispatchQueue.global(qos: .background)
    dispatchQueue.async(execute: {

        if let data = NSData(contentsOfFile: self.audioFilePath())
        {
            do{
                let session = AVAudioSession.sharedInstance()

                try session.setCategory(AVAudioSession.Category.playback)
                try session.setActive(true)

                self.audioPlayer = try AVAudioPlayer(data: data as Data)
                self.audioPlayer.delegate = self
                self.audioPlayer.prepareToPlay()
                self.audioPlayer.play()
            }
            catch{
                print("\(error)")
            }
        }
    });
}

@IBAction func stopButtonClicked(sender : AnyObject){

    if let player = self.audioPlayer{
        player.stop()
    }

    if let record = self.audioRecorder{

        record.stop()
    }

    let session = AVAudioSession.sharedInstance()
    do{
        try session.setActive(false)
    }
    catch{
        print("\(error)")
    }
}

@IBAction func recordButtonClicked(sender : AnyObject){

    let session = AVAudioSession.sharedInstance()

    do{
        try session.setCategory(AVAudioSession.Category.playAndRecord)
        try session.setActive(true)
        session.requestRecordPermission({ (allowed : Bool) -> Void in

            if allowed {
                self.startRecording()
            }
            else{
                print("We don't have request permission for recording.")
            }
        })
    }
    catch{
        print("\(error)")
    }
}

func startRecording(){

    self.playButton.isEnabled = false
    self.recordButton.isEnabled = false
    self.stopButton.isEnabled = true

    do{

        let fileURL = NSURL(string: self.audioFilePath())!
        self.audioRecorder = try AVAudioRecorder(url: fileURL as URL, settings: self.audioRecorderSettings() as! [String : AnyObject])

        if let recorder = self.audioRecorder{
            recorder.delegate = self

            if recorder.record() && recorder.prepareToRecord(){
                print("Audio recording started successfully")
            }
        }
    }
    catch{
        print("\(error)")
    }
}

func audioFilePath() -> String{

    let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
    let filePath = path.stringByAppendingPathComponent(path: "test.caf") as String

    //let filePath = NSBundle.mainBundle().pathForResource("mySong", ofType: "mp3")!
    return filePath
}

func audioRecorderSettings() -> NSDictionary{

    let settings = [AVFormatIDKey : NSNumber(value: Int32(kAudioFormatMPEG4AAC)), AVSampleRateKey : NSNumber(value: Float(16000.0)), AVNumberOfChannelsKey : NSNumber(value: 1), AVEncoderAudioQualityKey : NSNumber(value: Int32(AVAudioQuality.medium.rawValue))]

    return settings as NSDictionary
}

//MARK: AVAudioPlayerDelegate methods

func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {

    if flag == true{
        print("Player stops playing successfully")
    }
    else{
        print("Player interrupted")
    }

    self.recordButton.isEnabled = true
    self.playButton.isEnabled = false
    self.stopButton.isEnabled = false
}

//MARK: AVAudioRecorderDelegate methods

func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {

    if flag == true{
        print("Recording stops successfully")
    }
    else{
        print("Stopping recording failed")
    }

    self.playButton.isEnabled = true
    self.recordButton.isEnabled = false
    self.stopButton.isEnabled = false
}
}


