//
//  SoundViewController.swift
//  CastroSoundBoard
//
//  Created by Estefany Castro on 31/10/23.
//

import UIKit
import AVFoundation

class SoundViewController: UIViewController {

    @IBOutlet weak var grabarButton: UIButton!
    @IBOutlet weak var reproducirButton: UIButton!
    @IBOutlet weak var nombreTextField: UITextField!
    @IBOutlet weak var agregarButton: UIButton!
    
    @IBOutlet weak var volumenSlider: UISlider!
    @IBOutlet weak var duracionLabel: UILabel!
    
    var recordingTimer: Timer?
    var recordingTime: TimeInterval = 0
    
    var grabarAudio:AVAudioRecorder?
    var reproducirAudio:AVAudioPlayer?
    var audioURL:URL?
    
    
    @IBAction func grabarTapped(_ sender: Any) {
        if grabarAudio!.isRecording {
               // Detener la grabación
               grabarAudio?.stop()
               // Detener el temporizador
               recordingTimer?.invalidate()
               recordingTimer = nil
               // Cambiar texto del botón grabar
               grabarButton.setTitle("GRABAR", for: .normal)
               reproducirButton.isEnabled = true
               agregarButton.isEnabled = true
           } else {
               // Empezar a grabar
               grabarAudio?.record()
               // Iniciar el temporizador para actualizar la duración
               recordingTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateRecordingTime), userInfo: nil, repeats: true)
               // Cambiar el texto del botón grabar a detener
               grabarButton.setTitle("DETENER", for: .normal)
               reproducirButton.isEnabled = false
           }
    }
    
    
    @IBAction func reproducirTapped(_ sender: Any) {
        do {
            try reproducirAudio = AVAudioPlayer(contentsOf: audioURL!)
            reproducirAudio!.volume = volumenSlider.value
            reproducirAudio!.play()
            print("Reproduciendo")
        } catch {}
    }
    
    
    @IBAction func agregarTapped(_ sender: Any) {
        let context = (UIApplication.shared.delegate as!
                       AppDelegate).persistentContainer.viewContext
        let grabacion = Grabacion(context: context)
        grabacion.nombre = nombreTextField.text
        grabacion.audio = NSData(contentsOf: audioURL!)! as Data
        grabacion.duracion = recordingTime
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        navigationController!.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarGrabacion()
        reproducirButton.isEnabled = false
        agregarButton.isEnabled = false
        
        // Configurar el control de volumen
        volumenSlider.minimumValue = 0.0 // Valor mínimo de volumen
        volumenSlider.maximumValue = 100.0 // Valor máximo de volumen
        volumenSlider.value = 50.0 // Valor inicial de volumen (puede ser ajustado)
        
        // Asociar la acción para el control de volumen
        volumenSlider.addTarget(self, action: #selector(volumenChanged), for: .valueChanged)
    }
    
    @objc func updateRecordingTime() {
        recordingTime += 1
        duracionLabel.text = formattedTime(recordingTime)
    }
    
    @objc func volumenChanged() {
        let volumen = volumenSlider.value // Obtener el valor del control deslizante
        reproducirAudio?.volume = volumen // Asignar el volumen al reproductor de audio
    }
    
    func formattedTime(_ time: TimeInterval) -> String {
        let seconds = Int(time) % 60
        let minutes = (Int(time) / 60) % 60
        let hours = Int(time) / 3600
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    func configurarGrabacion(){
        do {
            //creando sesion de audio let
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default,
                                    options: [])
            try session.overrideOutputAudioPort (.speaker)
            try session.setActive(true)
            
            //creando direccion para el archivo de audio
            let basePath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask,
                                                                      true).first!
            let pathComponents = [basePath, "audio.m4a" ]
            audioURL = NSURL.fileURL(withPathComponents: pathComponents)!
            
            //impresion de ruta donde se guardan los archivos
            print ("*********************")
            print (audioURL!)
            print ("********************")
            
            //crear opciones para el grabador de audio
            var settings:[String:AnyObject] = [:]
            settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
            settings[AVSampleRateKey] = 44100.0 as AnyObject?
            settings[AVNumberOfChannelsKey] = 2 as AnyObject?
            
            //crear el objeto de grabacion de audio
            grabarAudio = try AVAudioRecorder(url: audioURL!, settings: settings)
            grabarAudio!.prepareToRecord ()
            
        } catch let error as NSError{
            print(error)
        }
    }
}
