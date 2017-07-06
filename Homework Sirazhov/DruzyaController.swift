//
//  ViewController.swift
//  HomeWorkMessenger
//
//  Created by Raimbek Sirazhov on 04.07.17.
//  Copyright © 2017 Raimbek Sirazhov. All rights reserved.
//

import UIKit
import CoreData



class DruzyaController: UICollectionViewController, UICollectionViewDelegateFlowLayout,NSFetchedResultsControllerDelegate {
    
    private let cellId = "cellId"
//    var messages: [Messages]?
    lazy var fetchedResultsController: NSFetchedResultsController = { () -> NSFetchedResultsController<Friend> in
        let fetchRequest:NSFetchRequest<Friend> = Friend.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastMessage.date", ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "lastMessage != nil")
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
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
            let lastItem = self.fetchedResultsController.sections![0].numberOfObjects - 1
            let indexPath = IndexPath(item: lastItem, section: 0)
            self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
        })
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "HomeWork"
        collectionView?.backgroundColor = UIColor.white
        collectionView?.alwaysBounceVertical = true
        collectionView?.register(MessageCell.self, forCellWithReuseIdentifier: cellId)
        setupData()
        do {
            try fetchedResultsController.performFetch()
        } catch let err {
            print(err)
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Новая смска", style: .plain, target: self, action: #selector(newSms))
    }
    
    func newSms () {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let raim = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
        raim.name = "Раимбек Сиражов"
        raim.kartinkaImya = "rs"
        _=DruzyaController.createMessageWithText(text: "Добро пожаловать типа чата, хз что это))))", friend: raim, minutesAgo: 0, context: context)
        
        let samal = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
        samal.name = "Самал Кумарова"
        samal.kartinkaImya = "sk"
        _=DruzyaController.createMessageWithText(text: "Зачем так делать?", friend: samal, minutesAgo: 0, context: context)
        }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = fetchedResultsController.sections?[section].numberOfObjects {
            return count
        }
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MessageCell
        
        let friend = fetchedResultsController.object(at: indexPath) as! Friend
        cell.message = friend.lastMessage
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: view.frame.width, height: 100)
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let layout = UICollectionViewFlowLayout()
        let controller  = ChatLogController(collectionViewLayout: layout)
        let friend = fetchedResultsController.object(at: indexPath) as! Friend
        controller.friend = friend
        navigationController?.pushViewController(controller, animated: true)
    }
}


class MessageCell: BaseCell {
    var message: Messages? {
        didSet {
            nameLabel.text = message?.friend?.name
            if let kartinkaImya = message?.friend?.kartinkaImya {
                kartinkaProfilya.image = UIImage(named:kartinkaImya);
                prochelImageView.image = UIImage(named:kartinkaImya);
            }
            messageLabel.text = message?.text
            if let date = message?.date{
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm a"
                let elapsedTimeInSeconds = NSDate().timeIntervalSince(date as Date)
                let secondsInDay : TimeInterval = 60*60*24
                
                if(elapsedTimeInSeconds > 7*secondsInDay){
                    dateFormatter.dateFormat = "MM/dd/yy"
                } else if elapsedTimeInSeconds > secondsInDay{
                    dateFormatter.dateFormat = "EEE"
                }
                timeLabel.text = dateFormatter.string(from: date as Date)
            }
            
        }
    }
    
    let kartinkaProfilya: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 34
        imageView.layer.masksToBounds = true
        return imageView
    }()
    let liniyaDeleniya: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        return view
    }()
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Имя"
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Смс"
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "12:15"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .right
        return label
    }()
    let prochelImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        return imageView
    }()
    override func setupViews() {
        
        addSubview(kartinkaProfilya)
        addSubview(liniyaDeleniya)
        setupContainerView()
        
        kartinkaProfilya.image  = UIImage(named: "rs")
        prochelImageView.image  = UIImage(named: "rs")
        
        
        addConstraintsWithFormat(format: "H:|-14-[v0(68)]", views: kartinkaProfilya)
        addConstraintsWithFormat(format: "V:[v0(68)]", views: kartinkaProfilya)
        addConstraint(NSLayoutConstraint.init(item: kartinkaProfilya, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        addConstraintsWithFormat(format: "H:|-82-[v0]|", views: liniyaDeleniya)
        addConstraintsWithFormat(format: "V:[v0(1)]|", views: liniyaDeleniya)
    }
    private func setupContainerView() {
        let containerView = UIView()
        addSubview(containerView)
        addConstraintsWithFormat(format: "H:|-90-[v0]|", views: containerView)
        
        addConstraintsWithFormat(format: "V:[v0(50)]", views: containerView)
        addConstraint(NSLayoutConstraint.init(item: containerView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        containerView.addSubview(nameLabel)
        containerView.addSubview(messageLabel)
        containerView.addSubview(timeLabel)
        containerView.addSubview(prochelImageView)
        containerView.addConstraintsWithFormat(format: "H:|[v0][v1(80)]-12-|", views: nameLabel,timeLabel)
        
        containerView.addConstraintsWithFormat(format: "V:|[v0][v1(24)]|", views: nameLabel,messageLabel)
        containerView.addConstraintsWithFormat(format: "H:|[v0]-8-[v1(20)]-12-|", views: messageLabel,prochelImageView)
        
        containerView.addConstraintsWithFormat(format: "V:|[v0(24)]", views: timeLabel)
        containerView.addConstraintsWithFormat(format: "V:[v0(20)]|", views: prochelImageView)
        
    }
}
extension UIView {
    func addConstraintsWithFormat(format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
    
}
class BaseCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super .init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setupViews() {
    }
}


