//
//  FriendsControllerHelper.swift
//  Homework Sirazhov
//
//  Created by Raimbek Sirazhov on 04.07.17.
//  Copyright © 2017 Raimbek Sirazhov. All rights reserved.
//
import UIKit
import CoreData

extension DruzyaController {
    func clearData() {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        if let context = delegate?.persistentContainer.viewContext {
            do {
                let entityNames = ["Friend", "Messages"]
                for entityName in entityNames {
                    let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
                    let objects = try(context.fetch(fetchRequest)) as? [NSManagedObject]
                    for object in objects! {
                        context.delete(object)
                    }
                }
                
                try(context.save())
                
            } catch let err {
                print(err)
            }
        }

    }
    
    func setupData() {
        clearData()
        let delegate = UIApplication.shared.delegate as? AppDelegate
        if let context = delegate?.persistentContainer.viewContext {
            
            createAizhanMessagesWithContext(context: context)
            createDinaMessagesWithContext(context: context)
            createAselyaMessagesWithContext(context: context)
            do {
               try(context.save())
            } catch let err {
                print(err)
            }
        }
    }
    private func createDinaMessagesWithContext(context: NSManagedObjectContext) {
        let dina = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
        dina.name = "Дина Сулетаева"
        dina.kartinkaImya = "ds"
        _=DruzyaController.createMessageWithText(text: "Я здесь новенькая", friend: dina, minutesAgo: 4, context: context)
        // otvet
        _=DruzyaController.createMessageWithText(text: "Как твои дела?", friend: dina, minutesAgo: 1, context: context, isSender: true)
        _=DruzyaController.createMessageWithText(text: "Сегодня был очень плодотворный день для меня, я выполнял разные задачи и так далее, искал работу и в супермаркете увидел тебя", friend: dina, minutesAgo: 1, context: context, isSender: true)
    }
    private func createAselyaMessagesWithContext(context: NSManagedObjectContext) {
        let aselya = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
        aselya.name = "Аселя"
        aselya.kartinkaImya = "as"
        _=DruzyaController.createMessageWithText(text: "Что я здесь потеряла, что за чат такой?", friend: aselya, minutesAgo: 8 * 60 * 24, context: context)
    }


    private func createAizhanMessagesWithContext(context: NSManagedObjectContext) {
        let aizhan = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
        aizhan.name = "Айжан Исмагулова"
        aizhan.kartinkaImya = "ai"
        
        _=DruzyaController.createMessageWithText(text: "Модель", friend: aizhan, minutesAgo: 2, context: context)
        _=DruzyaController.createMessageWithText(text: "EAT Models", friend: aizhan, minutesAgo: 4, context: context)
        _=DruzyaController.createMessageWithText(text: "@ismagulova", friend: aizhan, minutesAgo: 20, context: context)
        // otvet
        _=DruzyaController.createMessageWithText(text: "Спасибо за ссылку в Инстаграм, прими заявку", friend: aizhan, minutesAgo: 1, context: context, isSender: true)
        _=DruzyaController.createMessageWithText(text: "Как твои дела?", friend: aizhan, minutesAgo: 1, context: context, isSender: true)
        _=DruzyaController.createMessageWithText(text: "Но ты не заметила меня", friend: aizhan, minutesAgo: 1, context: context, isSender: true)
}
    
    static func createMessageWithText(text: String, friend: Friend, minutesAgo: Double, context: NSManagedObjectContext, isSender: Bool = false) -> Messages {
        let message = NSEntityDescription.insertNewObject(forEntityName: "Messages", into: context) as! Messages
        message.friend = friend
        message.text = text
        message.date = NSDate().addingTimeInterval(-minutesAgo * 60)
        message.isSender = NSNumber(booleanLiteral: isSender) as! Bool
        friend.lastMessage = message
        return message
    }
//    func loadData() {
//        let delegate = UIApplication.shared.delegate as? AppDelegate
//        if let context = delegate?.persistentContainer.viewContext {
//            if let friends = fetchFriends() {
//                messages = [Messages]()
//                for friend in friends {
//                    print(friend.name as Any)
//                    let fetchRequest:NSFetchRequest<Messages> = Messages.fetchRequest()
//                    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
//                    fetchRequest.predicate = NSPredicate(format: "friend.name = %@", friend.name!)
//                    fetchRequest.fetchLimit = 1
//                    do {
//                        let fetchedMessages = try(context.fetch(fetchRequest) as? [Messages])
//                        messages?.append(contentsOf: fetchedMessages!)
//                    } catch let err {
//                        print(err)
//                    }
//                }
//                messages = messages?.sorted(by: {$0.date!.compare($1.date! as Date) == .orderedDescending})
//                
//            }
//           
//            
//        }
//    }
//    
//    private func fetchFriends() -> [Friend]? {
//        let delegate = UIApplication.shared.delegate as? AppDelegate
//        if let context = delegate?.persistentContainer.viewContext {
//            let request:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Friend")
//            do {
//                return try context.fetch(request) as? [Friend]
//            } catch let err {
//                print(err)
//            }
//
//    }
//        return nil
//    }
}
