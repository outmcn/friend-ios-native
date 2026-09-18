import SwiftUI

struct RechargeView: View {
    @State private var selected = 1
    let options = [10, 50, 100, 500]
    var body: some View {
        ZStack { Color(.systemGroupedBackground).ignoresSafeArea(); VStack(spacing: 22) {
            Text("账户充值").font(.title2.bold()).padding(.top, 20)
            Text("选择充值金额").font(.headline)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) { ForEach(options, id: \.self) { amount in Button { selected = amount } label: { Text("\(amount) 金币").frame(maxWidth: .infinity).frame(height: 52).background(selected == amount ? Color(red:0.95,green:0.80,blue:0.38) : Color.white).foregroundStyle(.black).clipShape(RoundedRectangle(cornerRadius: 12)).overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(red:0.95,green:0.80,blue:0.38),lineWidth: 1)) } } }
            Text("充值功能待接入支付服务").font(.footnote).foregroundStyle(.secondary)
            Button("确认充值") { }.frame(maxWidth: .infinity).frame(height: 48).buttonStyle(.borderedProminent).tint(Color(red:0.31,green:0.33,blue:0.53))
            Spacer()
        }.padding(24) }
        .navigationTitle("账户充值").navigationBarTitleDisplayMode(.inline)
    }
}
