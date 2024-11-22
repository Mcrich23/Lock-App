//
//  PasskeysEducationView.swift
//  Lock
//
//  Created by Morris Richman on 11/21/24.
//

import SwiftUI

struct PasskeysEducationView: View {
    let timer = UpsideDownAccuteTriangle.defaultTimer
    
    var publicKeyColor: Color {
        Color.purple.mix(with: .primary, by: 0.2)
    }
    
    var publicKeyText: Text {
        Text("public")
            .foregroundStyle(publicKeyColor)
    }
    
    var privateKeyColor: Color {
        Color.green.mix(with: .primary, by: 0.2)
    }
    
    var privateKeyText: Text {
        Text("private")
            .foregroundStyle(privateKeyColor)
    }
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Multi-Factor Authentication: Passkeys")
                    .font(.title)
                    .bold()
                    .multilineTextAlignment(.center)
                
                Text("One of the safest and newest options available is called Passkeys. Built by the FIDO Alliance, a group of companies that work together to create and standardize a protocol for secure authentication, Passkeys has been built to act as a digital replica of what a physical authentication key is. When you setup a Passkey, the online service you are using creates two keys: one ") + privateKeyText + Text(" and one ") + publicKeyText + Text(". The ") + privateKeyText + Text(" key is shared with you, and the ") + publicKeyText + Text(" key is saved by the service.")
                
                keyCreationGraphic
                
                Text("For an attacker, the ") + publicKeyText + Text(" key is useless. It's only purpose is to help the service ensure its you logging in. When you login with Passkeys, the service sends you a challenge created with the ") + publicKeyText + Text(" key. Your browser/password manager then uses the ") + privateKeyText + Text(" key to solve the challenge. Your browser/password manager then sends back the solved challenge.")
                
                authenticationGraphic
                    .padding(.vertical, 25)
                
                Text("Once the service has validated it is correct, you are then logged in. Because of this process, your ") + privateKeyText + Text(" key is never revealed, which makes Passkey phishing and other social engineering attacks impossible.")
            }
            .frame(maxWidth: 800)
            .padding()
            .frame(maxWidth: .infinity)
        }
    }
    
    private var authenticationGraphic: some View {
        HStack(spacing: 60) {
            VStack(spacing: 15) {
                cloudKeyImage
                    .frame(width: 75, height: 75)
                
                Image(systemName: "arrow.down")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
                
                GroupBox {
                    Text("Service Challenge")
                }
                
                Image(systemName: "arrow.down")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
                
                GroupBox {
                    Text("1000110000100010010110\n10010011111010100101101\n100011000010001001010")
                        .fixedSize()
                }
                .frame(height: 100)
                .overlay(alignment: .trailing) {
                    Image(systemName: "arrow.right")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25)
                        .offset(x: 80)
                }
            }
            
            VStack {
                EmptyView()
            }
            
            VStack(spacing: 15) {
                cloudKeyImage
                    .frame(width: 75, height: 75)
                
                Image(systemName: "arrow.up")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
                
                GroupBox {
                    Text("Service Challenge")
                }
                
                Image(systemName: "arrow.up")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
                
                clientKeyImage
                    .frame(width: 75, height: 100)
            }
        }
    }
    
    private var cloudKeyImage: some View {
        Image(systemName: "cloud")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundStyle(publicKeyColor)
            .overlay(content: {
                Image(systemName: "key.horizontal.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(0.45)
                    .offset(x: -1, y: 3)
                    .foregroundStyle(publicKeyColor)
            })
    }
    
    private var clientKeyImage: some View {
        Image(systemName: "person.badge.key.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundStyle(privateKeyColor)
    }
    
    private var keyCreationGraphic: some View {
        ZStack {
            UpsideDownAccuteTriangle(timer: timer, visibleSides: [.right])
                .environment(\.direction, .left)
            UpsideDownAccuteTriangle(timer: timer, visibleSides: [.left])
                .environment(\.direction, .right)
        }
        .rotation3DEffect(.degrees(180), axis: (x: 1, y: 0, z: 0))
        .frame(width: 200, height: 200)
        .overlay(alignment: .bottomLeading) {
            clientKeyImage
                .frame(width: 50, height: 50)
                .background(
                    Color(uiColor: .systemBackground)
                        .offset(x: -5, y: 10)
                )
                .offset(x: -5, y: 0)
        }
        .overlay(alignment: .bottomTrailing) {
            cloudKeyImage
                .frame(width: 60, height: 60)
                .background(
                    Color(uiColor: .systemBackground)
                        .offset(x: -0, y: 12)
                )
                .offset(x: 25, y: 0)
        }
        .overlay(alignment: .top) {
            Image(systemName: "building.2.crop.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 75, height: 75)
                .foregroundStyle(Color.orange)
                .background(
                    Color(uiColor: .systemBackground)
                        .frame(width: 75, height: 75)
                        .clipShape(Circle())
                )
                .offset(x: 0, y: -40)
        }
        .scaleEffect(0.7)
    }
}

#Preview {
    PasskeysEducationView()
}
