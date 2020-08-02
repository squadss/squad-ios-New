# Squads



### 开发必读

使用RxSwift+RxCocoa+ReactorKit框架开发, 开发前需了解这些库的基础用法

### 目录结构

- Extensions, 主要收藏一些类的扩展方法
- Common, 定义了一些常用类, 开发时可以直接选择继承它, 少写一些重复代码
- Networking, 网络服务都写在这里, 在这里定义接口模型
- Config, 配置类, 在这里定义项目中使用到的账号, 主题颜色, 本地持久化管理
- Tool, 定义一些常用的工具类, 封装类
- Libraries, 存放一些第三方库, 一般不支持cocoapod引入的会放在这里
- Business, 业务层, 平时开发都在这个文件夹下, 对应子文件夹有Activities, Flicks, Channesl, Squad, My文件夹
- Resources, 存放本地资源的, 比如: 字体, Json文件, static.html等等

### 开发资料<br/>

【接口文档】http://115.159.208.16:8888/api/swagger-ui.html<br/>
【交互设计】https://www.figma.com/proto/F2DJVCtZMtaWAI3VIAJmt6/SQUADS<br/>
【效果图】https://www.figma.com/file/F2DJVCtZMtaWAI3VIAJmt6/SQUADS?node-id=0%3A1<br/>
【腾讯IM】https://cloud.tencent.com/document/product/269/32675<br/>
【开发计划】https://www.yuque.com/docs/share/3dc9bfe6-2309-4be2-9933-5d2162c84422?#dB3n<br/>
【开发需求问题】https://docs.qq.com/sheet/DWUh0aW9Jd3l4QkFj<br/>
【产品建议收集】https://docs.qq.com/doc/DT0Jtd2piWXVXbEZz<br/>



### 进入开发

1. 使用Terminal打开squads-ios目录, 执行命令

   ```
   pod install
   ```

   将项目所需要的依赖库下载到本地, 然后执行命令

   ```
   open Squds.xcworkspace
   ```

   打开项目后, 键盘快捷键输入 **common + R** 开始运行程序

2. 业务模块的代码存放在Business目录下, 根据对应功能在对应目录下开发即可. 

3. 项目采用MVVM模式使用RxSwift+ReactorKit框架进行开发, 所以第一步在创建UIViewController时, 需要继承自ReactorViewController, 然后创建一个ViewModel文件, 命名为XXXXReactor并继承自Reactor类.

    举例: 要开发邀请好友界面, 第一步在Squad目录下创建一个SquadInvithNewViewController类:

   ```
   import UIKit
   import RxSwift
   import RxDataSources
   import Contacts
   
   class SquadInvithNewViewController: ReactorViewController<SquadInvithNewReactor> {
   	override func bind(reactor: SquadInvithNewReactor) { 
   		//TODO: 实现逻辑
   	}
   }
   ```

   这里的SquadInvithNewReactor其实是ViewModel类, 接着我们在当前目录Reactor下创建此文件:

   ```
   import Foundation
   import ReactorKit
   import RxSwift
   import RxCocoa
   
   class SquadInvithNewReactor: Reactor {
       
       enum Action {
           //TODO:
       }
       
       enum Mutation {
          //TODO: 
       }
       
       struct State {
       	//TODO: 
       }
       
       var initialState: State
       init() {
           initialState = State()
       }
       
       func mutate(action: Action) -> Observable<Mutation> {
           //TODO: 
       }
       
       func reduce(state: State, mutation: Mutation) -> State {
           //TODO: 
       }
   }
   ```

   这是固定格式, 每一个Reactor都需要有这些功能及方法. 如果不熟悉此框架, 可以通过[点击这里](https://github.com/ReactorKit/ReactorKit)去学习它.

4. 页面布局

   采用SnapKit框架自动布局, 在项目中普遍存在, 不过有些复杂的布局建议还是采用Frame方案处理, 因为使用SnapKit这种autoLayout框架, 它的本质还是会通过算法转为frame进行布局, 所以为了避免不必要计算浪费性能, 建议使用Frame.

5. 设置颜色, 框架中为了适配暗黑模式, 预设了几个颜色值, 存于与Config->Color->UIColor+Squads.swift中, 在项目中使用时:

```
// 原生的颜色配置
view.background = UIColor.white
// 适配了暗黑模式的颜色配置
view.theme.background = UIColor.background
```

6. 程序的主入口

   iOS13中将应用的主入口和屏幕的主入口进行区分了, 分为两个文件AppDelete.swift, SceneDelegate.swift, 如果要自定义屏幕的主入口, 可以在SceneDelegate.swift文件中的**scene(scene: , willConnectTo: , options: )** 方法中进行:

   ```
   func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
   	guard let windowScene = (scene as? UIWindowScene) else { return }
   	window = UIWindow(windowScene: windowScene)
   	window?.backgroundColor = .white
   	Application.shared.presentInitialScreent(in: window)
   	window?.makeKeyAndVisible()
   }
   ```

   

7. 其中Application为自定义的类, 主要的作用是为了处理当前状态下需要显示的主屏幕, 如果未登录状态, 就显示Login页面, 如果已登录没有可用的Squad, 就显示CreateSquad页面, 如果已经登录并且存在一个可用的Squad就显示Squad详情页面, 后期如果需要添加引导页面(Screen Guide)也需要通过此类改变其中的显示逻辑处理.