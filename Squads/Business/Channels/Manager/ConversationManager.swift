//
//  ConversationManager.swift
//  Squads
//
//  Created by 武飞跃 on 2020/7/25.
//  Copyright © 2020 Squads. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay
import MessageKit
//
//public final class MessageElem {
//
//    private var dateMessage: Date?
//
//    var timestamp: Date {
//        return message.timestamp as Date
//    }
//
//    //是否为有效的消息类型
//    var isValidType: Bool {
//        return dateMessage == nil
//    }
//
//    public private(set) var message: V2TIMMessage!
//    public var messageSender: SenderType?
//
//    /// 时间戳构造方法
//    ///
//    /// - Parameter dateMessage: 日期
//    public init(dateMessage: Date) {
//        self.dateMessage = dateMessage
//    }
//
//    public init(message: V2TIMMessage) {
//        self.message = message
//    }
//
//    /// 文本构造方法
//    ///
//    /// - Parameter text: 文本内容
//    public init(text: String, sender: SenderType?) {
//
//        let textEle = V2TIMTextElem()
//        textEle.text = text
//
//        let msgEle = V2TIMMessage()
//        msgEle.textElem = textEle
//
//        self.message = msgEle
//        self.messageSender = sender
//    }
//
//
//    /// 语音构造方法
//    ///
//    /// - Parameters:
//    ///   - data: 音频二进制数据
//    ///   - dur: 音频时长
//    public init(data: Data, dur: Int32, sender: SenderType?) {
//
//        let soundEle = TIMSoundElem()
//
//        if let path = saveDataToLocal(with: data) {
//            soundEle.path = path
//            soundEle.second = dur
//        }
//
//        let msgEle = TIMMessage()
//        msgEle.add(soundEle)
//
//        self.message = msgEle
//        self.messageSender = sender
//    }
//
//    // 将当前消息转为文本描述
//    var description: String {
//        return "哈喽"
//    }
//
//    var dateString: String {
//        return "just"
//    }
//}
//
////MARK: - 语音消息
//extension MessageElem {
//
//    /// 保存数据到本地
//    ///
//    /// - Parameter with: 语音data
//    private func saveDataToLocal(with data: Data) -> String? {
//
//        guard let loginId = TIMManager.sharedInstance().getLoginUser() else { return nil }
//
//        let cachePath = PathUtility.getCachePath()
//
//        let soundSaveDir = "\(cachePath)/\(loginId)/Audio"
//
//        if PathUtility.isExistFile(path: soundSaveDir) == false {
//            do {
//                try FileManager.default.createDirectory(atPath: soundSaveDir, withIntermediateDirectories: true, attributes: nil)
//            }catch {
//                return nil
//            }
//        }
//
//        let durationString = String(format:"%llu", Date().timeIntervalSince1970)
//        let soundSavePath = "\(soundSaveDir)/\(durationString)"
//
//        if PathUtility.isExistFile(path: soundSavePath) == false {
//            let state = FileManager.default.createFile(atPath: soundSavePath, contents: nil, attributes: nil)
//            if !state {
//                return nil
//            }
//        }
//
//        let isWrite = NSData(data: data).write(toFile: soundSavePath, atomically: true)
//        if isWrite == false {
//            return nil
//        }
//        return soundSavePath
//    }
//
//    public func getSoundPath(succ: @escaping (URL?) -> Void, fail: @escaping TIMFail) {
//        guard let loginId = TIMManager.sharedInstance().getLoginUser(),
//            let elem = message.getElem(0) as? TIMSoundElem else { return }
//
//        let cachePath = PathUtility.getCachePath()
//        let audioDir = "\(cachePath)/\(loginId)"
//        var isDir: ObjCBool = false
//        let isDirExist = FileManager.default.fileExists(atPath: audioDir, isDirectory: &isDir)
//
//        if !(isDir.boolValue && isDirExist) {
//            let isCreateDir = PathUtility.createDirectory(atCache: loginId)
//            if isCreateDir == false {
//                return
//            }
//        }
//
//        let uuid = elem.uuid ?? ""
//        let path = "\(cachePath)/\(loginId)/" + uuid
//
//        if PathUtility.isExistFile(path: path) {
//            succ(URL(fileURLWithPath: path))
//        }
//        else {
//            elem.getSound(path, succ: {
//                succ(URL(fileURLWithPath: path))
//            }, fail: fail)
//        }
//
//    }
//
//}
//
//public struct PathUtility {
//    public static func getCachePath() -> String {
//        return NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
//    }
//
//    public static func isExistFile(path:String) -> Bool {
//        guard !path.isEmpty else{ return false }
//        return FileManager.default.fileExists(atPath: path)
//    }
//
//    public static func createDirectory(atCache dirName: String) -> Bool{
//        let dirPath = getFileCachePath(fileName: dirName)
//        if FileManager.default.fileExists(atPath: dirPath) {
//            return true
//        }
//        do {
//         try FileManager.default.createDirectory(atPath: dirPath, withIntermediateDirectories: true, attributes: nil)
//        }catch {
//            return false
//        }
//        return true
//    }
//
//    private static func getFileCachePath(fileName: String) -> String{
//        let path = getCachePath()
//        return NSString(string: path).appendingPathComponent(fileName)
//    }
//
//}
//
//
protocol ConversationDelegate: class {

    /// 将消息添加到当前会话的消息列表
    ///
    /// - Parameter msg: 当前的消息
    /// - Returns: 新的消息数组
    func addMsgToList(msg followMessage: MessageElem, lastMessage: TIMMessage?) -> Array<MessageElem>

    /// 对比两个消息,符合规则就添加时间戳
    ///   如果last为空,返回follow的时间戳,如果last不为空且对比follow已超过5分钟,返回follow的时间戳, 否则返回nil
    /// - Parameters:
    ///   - last: 最后一次的消息
    ///   - follow: 后来的消息
    /// - Returns: 时间文本/nil
    func timeTipOnNewMessageIfNeeded(last: Date?, follow: Date?) -> Date?

    /*  将TIMMessage数组转换成IMMessage数组

     元素排列规则为:
     ****** 文本0(数组最后一个元素).timeTip *******
     ****** 文本0 *******
     ****** 文本1.timeTip(如果时间较文本0超5分,才会添加) ******
     ****** 文本1 ******
     ****** 文本2 *******
     */
    func convertMessageElem(from array: Array<TIMMessage>) -> Array<MessageElem>
}

extension ConversationDelegate {

    public func timeTipOnNewMessageIfNeeded(last: Date?, follow: Date?) -> Date? {
        guard let followDate = follow else { return nil }
        if let lastDate = last {
            //判断时间间隔是否大于5分钟, 如果大于五分钟就返回followDate, 否则返回nil
            return followDate.timeIntervalSince(lastDate) > TimeInterval(5*60) ? followDate : nil
        }
        return followDate
    }

    func convertMessageElem(from array: Array<TIMMessage>) -> Array<MessageElem> {

        var tempArray = Array<MessageElem>()
        var prevMessage: TIMMessage?

//        for index in (0 ..< array.count).reversed() {
//
//            let message = array[index]
//            let currentTimestamp = message.timestamp()
//
//            if let date = currentTimestamp, index == array.count - 1 {
//                tempArray.append(MessageElem(dateMessage: date))
//            }
//
//            if  let prev = prevMessage,
//                let prevDate = prev.timestamp(),
//                let unwrappedDate = currentTimestamp {
//
//                //大于5分钟
//                let timeInterval = unwrappedDate.timeIntervalSince(prevDate)
//                if timeInterval > TimeInterval(5 * 60) {
//                    let msg = MessageElem(dateMessage: unwrappedDate)
//                    tempArray.append(msg)
//                }
//            }
//
//            prevMessage = message
//
//            let imamsg = MessageElem(message: message)
//            tempArray.append(imamsg)
//        }

        return tempArray

    }


    func addMsgToList(msg followMessage: MessageElem, lastMessage: TIMMessage?) -> Array<MessageElem> {

        var array = Array<MessageElem>()

//        if let timeTip = timeTipOnNewMessageIfNeeded(last: lastMessage?.timestamp(), follow: followMessage.timestamp) {
//            let dateMessage = MessageElem(dateMessage: timeTip)
//            array.append(dateMessage)
//        }

        array.append(followMessage)

        return array

    }
}

//
//class Conversation: ConversationDelegate {
//
//    private var conversation: TIMConversation
//    // 监听到新消息的回调
//    fileprivate var onReceiveMessageCompletion: ((TIMMessage) -> Void)?
//
//    // 记录当前页的消息列表
//    private var pageMessageList = Array<MessageElem>()
//
//    public init?(type: TIMConversationType, id: String) {
//        guard let conversation = TIMManager.sharedInstance().getConversation(type, receiver: id ) else {
//            return nil
//        }
//        self.conversation = conversation
//    }
//
//    public init(conversation: TIMConversation) {
//        self.conversation = conversation
//    }
//
//    ///  发送消息
//    ///
//    /// - Parameters:
//    ///   - message: 待发送的消息实例
//    ///   - result:
//    //FIXME: 将消息数组传出去
//    public func send(message: MessageElem, result: @escaping (Result<Void, GeneralError>) -> Void) {
//
//        conversation.send(message.message, succ: { [weak self] in
//
//            if self?.pageMessageList.isEmpty == true {
//                self?.pageMessageList.append(message)
//            }
//
//            result(.success(()))
//
//        }) { (code, description) in
//            if code == 80001 {
//                result(.failure(.custom("敏感词汇")))
//            } else {
//                result(.failure(.custom("Send failure!")))
//            }
//        }
//
//    }
//
//    /// 设置消息已读
//    ///
//    /// - Parameter message: SDK中的消息类型
//    public func alreadyRead(message: TIMMessage? = nil) {
//
//        //必须是接收到的消息, 才可主动设置为已读
//        guard message?.isSelf() == false || message == nil else {
//            //TODO: 筛选出最后一条对方的消息, 并设置为已读(数组排序要优化一下, 因为数据比较多)
//            return
//        }
//
//        conversation.setRead(message, succ: {
//            //设置已读成功,不处理回调
//        }) { (code, string) in
//            //FIXME: - 设置消息已读失败, 将造成对方监听消息已读回执的方法不执行
//        }
//    }
//
//    public func listenerNewMessage(completion:  @escaping (Array<MessageElem>) -> Void) {
//        self.onReceiveMessageCompletion = { [weak self] in
//            guard let this = self else { return }
//            //监听到的新消息
//            let message = MessageElem(message: $0)
//            //组成新的消息集合, 一块发出去
//            let lastMessage = this.conversation.getLastMsg()
//            let messageMap = this.addMsgToList(msg: message, lastMessage: lastMessage)
//            completion(messageMap)
//        }
//    }
//
//    public func free() {
//        onReceiveMessageCompletion = nil
//    }
//
//    /// 切换到本会话前，先加载本地的最后count条聊天的数据
//    ///
//    /// - Parameters:
//    ///   - count: 加载条数
//    ///   - completion: 异步回调,返回加载的message数组,数组不为空即为加载成功
//    public func loadRecentMessages(count:Int, completion:@escaping (Result<[MessageElem], GeneralError>) -> Void) {
//        //取到不包含timeTip和saftyTip的message数组
//        /*
//         消息排序规则:
//         前天信息
//         昨天信息
//         今天信息
//         刚刚信息
//         */
//        let topMessage = pageMessageList.first(where: { $0.isValidType })
//        loadRecentMessages(count: count, from: topMessage, completion: completion)
//    }
//
//
//    /// 加载最近的消息 以message为Key拿到count条数据
//    ///
//    /// - Parameters:
//    ///   - count: 加载的条数
//    ///   - message: 用于检索的message
//    ///   - completion: 返回加载的message数组,数组不为空即为加载成功
//    private func loadRecentMessages(count: Int,
//                                    from message: MessageElem?,
//                                    completion: @escaping (Result<[MessageElem], GeneralError>) -> Void){
//
//        conversation.getMessage(Int32(count), last: message?.message, succ: { [weak self] (anys) in
//
//                guard let messages = anys as? Array<TIMMessage> else { return }
//
//                if let tempArray = self?.convertMessageElem(from: messages) {
//                    if !tempArray.isEmpty {
//                        self?.pageMessageList = tempArray
//                    }
//                    completion(.success(tempArray))
//                }
//
//                //将本地加载的这页数据时间最近的一条筛选出来, 然后设置为已读
//                if let lastOtherMessage = messages.first(where: { $0.isSelf() == false }), lastOtherMessage.isPeerReaded() == false {
//                    self?.alreadyRead(message: lastOtherMessage)
//                }
//
//            }, fail: {code , description in
//                DispatchQueue.main.async {
//                    completion(.failure(.custom("加载消息发生未知错误")))
//                }
//        })
//    }
//}

//final class ConversationManager: NSObject {
//
//    static let shared = ConversationManager()
//
//    // 未读消息
//    private var unreadMessageRelay = BehaviorRelay<Int>(value: 0)
//    var unreadMessageObservable: Observable<Int> {
//        return unreadMessageRelay.asObservable()
//    }
//
//    // 消息通知
//    private var handlerNotificationRelay = PublishRelay<Conversation>()
//    var handlerNotificationObservable: Observable<Conversation> {
//        return handlerNotificationRelay.asObservable()
//    }
//
//    //当前聊天的对象
//    private var chattingConversation: Conversation?
//
//    // 会话列表
//    private var conversationList: Array<Conversation>? {
//        didSet {
//            let total: Int = conversationList?.reduce(0) { $0 + $1.unreadMessageCount } ?? 0
//            unreadMessageRelay.accept(total)
//        }
//    }
//
//    required override init() {
//        super.init()
//        TIMManager.sharedInstance()?.add(self)
//    }
//
//    deinit {
//        TIMManager.sharedInstance()?.remove(self)
//    }
//
//    /// 主动触发聊天
//    ///
//    /// - Parameters:
//    ///   - type: 聊天类型  单人或群组
//    ///   - id: 房间号
//    /// - Returns: 会话对象
//    public func holdChat(with type: TIMConversationType, id: String) -> Conversation? {
//        let wrappedConversation = Conversation(type: type, id: id)
//        chattingConversation = wrappedConversation
//        // 将改会话的未读消息减去总数
//        let unread = wrappedConversation?.unreadMessageCount ?? 0
//        unreadMessageRelay.accept(max(unreadMessageRelay.value - unread, 0))
//        return chattingConversation
//    }
//
//    public func getConversation() -> Array<Conversation> {
//        if conversationList == nil {
//            conversationList = TIMManager.sharedInstance()?.getConversationList().map {
//                return Conversation(conversation: $0)
//            }
//        }
//        return conversationList ?? []
//    }
//
//    public func clearConversationList() {
//        conversationList?.removeAll()
//        conversationList = nil
//    }
//}
//
//extension ConversationManager: TIMMessageListener {
//
//    public func onNewMessage(_ msgs: [Any]!) {
//
//        for anyObjcet in msgs {
//
//            guard
//                let message = anyObjcet as? TIMMessage,
//                let timConversation = message.getConversation() else { return }
//
//            //局部对象, 作用域仅在此方法内, 注意会调用deinit
//            let conversation = Conversation(conversation: timConversation)
//
//            //此会话是否存在聊天列表中
//            if let didExistingConversation = getConversation().first(where: { $0 == conversation }) {
//
//                // 监听到消息, 分发给对应的会话对象
//                didExistingConversation.onReceiveMessageCompletion?(message)
//
//                //正处于当前活跃的会话页面时,将消息设置为已读
//                if didExistingConversation == chattingConversation {
//                    chattingConversation?.alreadyRead(message: message)
//                    return
//                }
//
//                if message.isSelf() == false {
//                    //列表中,别的会话发过来的消息, 就给个通知
//                    handlerNotificationRelay.accept(conversation)
//                }
//
//                // 将未读消息数加1
//                unreadMessageRelay.accept(unreadMessageRelay.value + 1)
//            }
//            else {
//                //新的会话不在列表中,可能是对方先发起的聊天,需要插入到会话列表中
//                if conversationList == nil {
//                    conversationList = getConversation()
//                }
//                conversationList?.insert(conversation, at: 0)
//                handlerNotificationRelay.accept(conversation)
//            }
//        }
//    }
//
//}
