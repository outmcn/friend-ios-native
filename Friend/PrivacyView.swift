import SwiftUI

struct PrivacyView: View {
    @State private var values=[[false,false],[false]]
    let groups=[("通知设置",["接收新消息通知","通知显示消息详情"]),("其他设置",["屏蔽手机通讯录的联系人"])]
    var body: some View { ZStack{Color(.systemGroupedBackground).ignoresSafeArea();ScrollView{VStack(alignment:.leading,spacing:28){ForEach(0..<groups.count,id:\.self){g in VStack(alignment:.leading,spacing:0){Text(groups[g].0).font(.system(size:16,weight:.medium)).foregroundStyle(.secondary).padding(.horizontal,32).padding(.bottom,12);VStack(spacing:0){ForEach(0..<groups[g].1.count,id:\.self){i in HStack{Text(groups[g].1[i]).font(.system(size:14));Spacer();Button(values[g][i] ? "打开":"关闭"){values[g][i].toggle()}.font(.system(size:13)).foregroundStyle(.secondary);Toggle("",isOn:Binding(get:{values[g][i]},set:{values[g][i]=$0})).labelsHidden().tint(Color(red:.95,green:.80,blue:.38))}.padding(.horizontal,32).frame(height:68).overlay(alignment:.bottom){Color(.systemGray6).frame(height:1)}}}}}}.padding(.top,64)}}.navigationTitle("隐私设置").navigationBarTitleDisplayMode(.inline)}
}
