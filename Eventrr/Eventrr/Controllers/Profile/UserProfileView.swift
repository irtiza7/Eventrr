//
//  UserProfileView.swift
//  Eventrr
//
//  Created by Dev on 8/21/24.
//

import SwiftUI
import FirebaseAuth

struct UserProfileView: View {
    
    @Environment(\.navigationController) private var navigationController: UINavigationController?
    @State private var isShowingEditProfile = false
    @State private var isShowingChangePassword = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    private let viewModel = ProfileViewModel()
    
    var body: some View {
        ZStack {
            SwiftUIConstants.primaryBackgroundColor
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                Text("Profile")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 30)
                    .padding(.top, 40)
                
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "person")
                            .resizable()
                            .scaledToFit()
                            .frame(width: SwiftUIConstants.iconDimension, height: SwiftUIConstants.iconDimension)
                            .foregroundColor(SwiftUIConstants.primaryAccentColor)
                        
                        Text("Name")
                            .font(.headline)
                    }
                    
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: SwiftUIConstants.fieldsCornerRadius)
                            .strokeBorder(SwiftUIConstants.primaryAccentColor, style: StrokeStyle(lineWidth: 1.0))
                            .background(Color(SwiftUIConstants.primaryBackgroundColor)
                                .cornerRadius(SwiftUIConstants.fieldsCornerRadius))
                        
                        Text(viewModel.userModel?.name ?? "")
                            .font(.subheadline)
                            .padding(.leading, 8)
                            .padding(.vertical, 8)
                            .foregroundColor(SwiftUIConstants.primaryForegroundColor)
                    }
                    .frame(height: 50)
                }
                
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "envelope")
                            .resizable()
                            .scaledToFit()
                            .frame(width: SwiftUIConstants.iconDimension, height: SwiftUIConstants.iconDimension)
                            .foregroundColor(SwiftUIConstants.primaryAccentColor)
                        
                        Text("Email")
                            .font(.headline)
                    }
                    
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: SwiftUIConstants.fieldsCornerRadius)
                            .strokeBorder(SwiftUIConstants.primaryAccentColor, style: StrokeStyle(lineWidth: 1.0))
                            .background(Color(SwiftUIConstants.primaryBackgroundColor)
                                .cornerRadius(SwiftUIConstants.fieldsCornerRadius))
                        
                        Text(viewModel.userModel?.email ?? "")
                            .font(.subheadline)
                            .padding(.leading, 8)
                            .padding(.vertical, 8)
                            .foregroundColor(SwiftUIConstants.primaryForegroundColor)
                    }
                    .frame(height: 50)
                }
                
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "person.3.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: SwiftUIConstants.iconDimension, height: SwiftUIConstants.iconDimension)
                            .foregroundColor(SwiftUIConstants.primaryAccentColor)
                        
                        Text("Role")
                            .font(.headline)
                    }
                    
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: SwiftUIConstants.fieldsCornerRadius)
                            .strokeBorder(SwiftUIConstants.primaryAccentColor, style: StrokeStyle(lineWidth: 1.0))
                            .background(Color(SwiftUIConstants.primaryBackgroundColor)
                                .cornerRadius(SwiftUIConstants.fieldsCornerRadius))
                        
                        Text(viewModel.userModel?.role?.rawValue ?? "")
                            .font(.subheadline)
                            .padding(.leading, 8)
                            .padding(.vertical, 8)
                            .foregroundColor(SwiftUIConstants.primaryForegroundColor)
                    }
                    .frame(height: 50)
                }
                
                HStack(alignment: .center) {
                    Button(action: {
                        isShowingEditProfile.toggle()
                    }) {
                        Text("Edit Profile")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(SwiftUIConstants.secondaryAccentColor)
                            .foregroundColor(SwiftUIConstants.primaryAccentColor)
                            .cornerRadius(SwiftUIConstants.buttonCornerRadius)
                    }
                    
                    Button(action: {
                        isShowingChangePassword.toggle()
                    }) {
                        Text("Change Password")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(SwiftUIConstants.secondaryAccentColor)
                            .foregroundColor(SwiftUIConstants.primaryAccentColor)
                            .cornerRadius(SwiftUIConstants.buttonCornerRadius)
                    }
                }
                .padding(.top, 10)
                
                Divider()
                    .padding(.vertical, 20)
                
                Button(action: {
                    logoutUser()
                }) {
                    Text("LOGOUT")
                        .padding()
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .background(SwiftUIConstants.secondaryAccentColor)
                        .foregroundColor(SwiftUIConstants.redAccentColor)
                        .cornerRadius(SwiftUIConstants.buttonCornerRadius)
                }
                
                Spacer()
            }
            .padding()
        }
        .sheet(isPresented: $isShowingEditProfile) {
            EditProfileView()
        }
        .sheet(isPresented: $isShowingChangePassword) {
            ChangePasswordView()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("Okay")))
        }
    }
    
    private func  logoutUser() {
        if let errorMessage = viewModel.logout() {
            alertMessage = errorMessage
            showAlert = true
            return
        }
        navigationController?.popToRootViewController(animated: true)
    }
}

struct NavigationControllerKey: EnvironmentKey {
    static let defaultValue: UINavigationController? = nil
}

extension EnvironmentValues {
    var navigationController: UINavigationController? {
        get { self[NavigationControllerKey.self] }
        set { self[NavigationControllerKey.self] = newValue }
    }
}
