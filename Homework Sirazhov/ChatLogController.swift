//
//  ChatLogController.swift
//  Homework Sirazhov
//
//  Created by Raimbek Sirazhov on 04.07.17.
//  Copyright © 2017 Raimbek Sirazhov. All rights reserved.
//

import UIKit
import CoreData
class ChatLogController: UICollectionViewController, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private let cellId = "cellId"
    var friend: Friend? {
        didSet {
            navigationItem.title = friend?.name
        }
    }
    let smsInputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
        
    }()
    let inputTextField: UITextField = {
        let textField  = UITextField()
        textField.placeholder = "Введите сообщение..."
        return textField
    }()
    lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "send2"), for: .normal)
        button.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        return button
    }()
    lazy var openButton: UIButton = {
        let obutton = UIButton(type: .system)
        obutton.setImage(#imageLiteral(resourceName: "grid"), for: .normal)
        obutton.addTarget(self, action: #selector(handleUploadTap), for: .touchUpInside)
        return obutton
    }()
    func handleUploadTap () {
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFromPicker: UIImage?
        if let editedImage = info["UIImagePickerControlEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage =
            info["UIImagePickerControlEditedImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        if let selectedImage = selectedImageFromPicker {
            uploadToCoreData(image: selectedImage)
        }
        dismiss(animated: true, completion: nil)
    }
    func scaleImageWith(image:UIImage, newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    private func uploadToCoreData(image: UIImage) {
        let image = NSUUID().uuidString
        print("Сделано")
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    func handleSend () {
        print(inputTextField.text as Any)
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        DruzyaController.createMessageWithText(text: inputTextField.text!, friend: friend!, minutesAgo: 0, context: context, isSender: true)
        do {
            try context.save()
            inputTextField.text = nil
        } catch let err {
            print(err)
        }
        
    }
    
    var bottomConstraint: NSLayoutConstraint?
    
    func simulate() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        DruzyaController.createMessageWithText(text: "Смс высланное пару минут назад", friend: friend!, minutesAgo: 1, context: context)
        DruzyaController.createMessageWithText(text: "Сегодня замечательный день", friend: friend!, minutesAgo: 1, context: context)
        do {
            try context.save()
            } catch let err {
            print(err)
        }
    }
    
    
    lazy var fetchedResultesController: NSFetchedResultsController = { () -> NSFetchedResultsController<Messages> in
        let fetchRequest:NSFetchRequest<Messages> = Messages.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "friend.name = %@", self.friend!.name!)
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    var blockOperations = [BlockOperation]()
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?)  {
        if type == .insert {
            blockOperations.append(BlockOperation(block: { 
                self.collectionView?.insertItems(at: [newIndexPath!])
            }))
        }
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView?.performBatchUpdates({ 
            for operation in self.blockOperations {
                operation.start()
            }
        }, completion: { (completed) in
            let lastItem = self.fetchedResultesController.sections![0].numberOfObjects - 1
            let indexPath = IndexPath(item: lastItem, section: 0)
            self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
        })
    }
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        do {
            try fetchedResultesController.performFetch()
            print(fetchedResultesController.sections?[0].numberOfObjects as Any)
        } catch let err {
            print(err)
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Случайное смс", style: .plain, target: self, action: #selector(simulate))
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatLogMessageCell.self, forCellWithReuseIdentifier: cellId)
        view.addSubview(smsInputContainerView)
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: smsInputContainerView)
        view.addConstraintsWithFormat(format: "V:[v0(48)]", views: smsInputContainerView)
        
        let bottomConstraint = NSLayoutConstraint(item: smsInputContainerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraint(bottomConstraint)
        
        
        
        setupInputComponents()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    func handleKeyboardNotification(notification: NSNotification) {
        if notification.userInfo != nil {
            let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
            print(keyboardFrame as Any)
            let isKeyboardShowing = notification.name == NSNotification.Name.UIKeyboardWillShow
            containerViewBottomAnchor?.constant = isKeyboardShowing ? -keyboardFrame!.height : 0
            UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: { 
                self.view.layoutIfNeeded()
            }, completion: { (completed) in
                if (isKeyboardShowing) {
                    let lastItem = self.fetchedResultesController.sections![0].numberOfObjects - 1
                    let indexPath = IndexPath(item: lastItem, section: 0)
                    self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
                }
                
            })
        }
    }
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        inputTextField.endEditing(true)
    }
    
    var containerViewBottomAnchor: NSLayoutConstraint?
    private func setupInputComponents() {
        let topBorderView = UIView()
        topBorderView.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        smsInputContainerView.addSubview(inputTextField)
        smsInputContainerView.addSubview(sendButton)
        smsInputContainerView.addSubview(openButton)
        smsInputContainerView.addSubview(topBorderView)
        containerViewBottomAnchor = smsInputContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        containerViewBottomAnchor?.isActive = true
        smsInputContainerView.addConstraintsWithFormat(format: "H:|[v2(60)]-24-[v0][v1(60)]|", views: inputTextField, sendButton,openButton)
        
        smsInputContainerView.addConstraintsWithFormat(format: "V:|[v0]|", views: inputTextField)
        smsInputContainerView.addConstraintsWithFormat(format: "V:|[v0]|", views: sendButton)
        smsInputContainerView.addConstraintsWithFormat(format: "V:|[v0]|", views: openButton)
        smsInputContainerView.addConstraintsWithFormat(format: "H:|[v0]|", views: topBorderView)
        smsInputContainerView.addConstraintsWithFormat(format: "V:|[v0(0.5)]", views: topBorderView)

    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = fetchedResultesController.sections?[0].numberOfObjects {
            return count
        }
        return 0
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatLogMessageCell
        
        let message = fetchedResultesController.object(at: indexPath) as! Messages
        
        cell.messageTextView.text = message.text
        if let messageText = message.text, let kartinkaImya = message.friend?.kartinkaImya  {
            cell.profileImageView.image = UIImage(named: kartinkaImya)
            let size = CGSize.init(width: 250, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18)], context: nil)
            if !message.isSender {
                cell.messageTextView.frame = CGRect.init(x: 46 + 8, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
                cell.textPuzyrView.frame = CGRect.init(x: 48 - 10, y: -4, width: estimatedFrame.width + 16 + 8 + 16, height: estimatedFrame.height + 20 + 6)
                cell.messageImageView.frame = CGRect.init(x: 48 - 10, y: -4, width: estimatedFrame.width + 16 + 8 + 16, height: estimatedFrame.height)
                cell.profileImageView.isHidden = false
//                cell.textPuzyrView.backgroundColor = UIColor(white: 0.95, alpha: 1)
                cell.puzyrImageView.image = ChatLogMessageCell.greyPuzyrImage
                cell.puzyrImageView.tintColor = UIColor(white: 0.95, alpha: 1)
                cell.messageTextView.textColor = UIColor.black
            } else {
                cell.messageTextView.frame = CGRect.init(x: view.frame.width - estimatedFrame.width  - 16 - 16 - 8, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
                cell.textPuzyrView.frame = CGRect.init(x: view.frame.width - estimatedFrame.width - 16 - 8 - 16 - 10, y: -4, width: estimatedFrame.width + 16 + 8 + 10, height: estimatedFrame.height + 20 + 6)
                cell.profileImageView.isHidden = true
//                cell.textPuzyrView.backgroundColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
                   cell.puzyrImageView.image = ChatLogMessageCell.bluePuzyrImage
                cell.puzyrImageView.tintColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
                cell.messageTextView.textColor = UIColor.white
                
            }
            
        }
        
        
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let message = fetchedResultesController.object(at: indexPath) as! Messages
        if let messageText = message.text {
            
            let size = CGSize.init(width: 250, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18)], context: nil)
            return CGSize.init(width: view.frame.width, height: estimatedFrame.height + 20)
        }
        return CGSize.init(width: view.frame.width, height: 100)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(8, 0, 0, 0)
    }
}
class ChatLogMessageCell: BaseCell {
    let messageTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.text = "Примерная смска"
        textView.backgroundColor = UIColor.clear
        textView.isEditable = false
        return textView
    }()
    let textPuzyrView: UIView = {
        let view = UIView()
//        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        return view
    }()
    let messageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        return imageView
    }()
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        return imageView
    }()
    static let greyPuzyrImage = UIImage(named: "grey")!.resizableImage(withCapInsets: UIEdgeInsetsMake(22, 26, 22, 26)).withRenderingMode(.alwaysTemplate)
    static let bluePuzyrImage = UIImage(named: "blue")!.resizableImage(withCapInsets: UIEdgeInsetsMake(22, 26, 22, 26)).withRenderingMode(.alwaysTemplate)
    
    
    
    let puzyrImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = ChatLogMessageCell.greyPuzyrImage
        imageView.tintColor = UIColor(white: 0.90, alpha: 1)
        return imageView
    }()
    override func setupViews() {
        super.setupViews()
        addSubview(textPuzyrView)
        addSubview(messageTextView)
        addSubview(profileImageView)
        addConstraintsWithFormat(format: "H:|-8-[v0(30)]", views: profileImageView)
        addConstraintsWithFormat(format: "V:[v0(30)]|", views: profileImageView)
        textPuzyrView.addSubview(messageImageView)
        textPuzyrView.addSubview(puzyrImageView)
        textPuzyrView.addConstraintsWithFormat(format: "H:|[v0]|", views: puzyrImageView)
        textPuzyrView.addConstraintsWithFormat(format: "V:|[v0]|", views: puzyrImageView)
        textPuzyrView.addConstraintsWithFormat(format: "H:|[v0]|", views: messageImageView)
        textPuzyrView.addConstraintsWithFormat(format: "V:|[v0]|", views: messageImageView)
    }
}
