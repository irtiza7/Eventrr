//
//  EditProfileView.swift
//  Eventrr
//
//  Created by Dev on 8/21/24.
//

import SwiftUI
import FirebaseAuth

struct EditProfileView: View {
    
    @Environment(\.navigationController) private var navigationController: UINavigationController?
    @ObservedObject private var viewModel = EditProfileViewModel()
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var showSpinner = false
    
    var body: some View {
        ZStack {
            SwiftUIConstants.primaryBackgroundColor
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                Text("Edit Profile")
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
                    
                    TextField("", text: $viewModel.modifiedName)
                        .padding()
                        .foregroundColor(SwiftUIConstants.primaryForegroundColor)
                        .overlay(RoundedRectangle(cornerRadius: SwiftUIConstants.fieldsCornerRadius).strokeBorder(SwiftUIConstants.primaryAccentColor, style: StrokeStyle(lineWidth: 1.0)))
                        .cornerRadius(SwiftUIConstants.fieldsCornerRadius)
                }
                .padding(.bottom, 10)
                
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
                    
                    Picker("Role", selection: $viewModel.selectedRole) {
                        ForEach(viewModel.userRolesList, id: \.self) { role in
                            Text(role.rawValue)
                                .tag(role)
                                .foregroundColor(SwiftUIConstants.primaryAccentColor)
                        }
                    }
                    .pickerStyle(.wheel)
                    .padding()
                    .foregroundColor(SwiftUIConstants.primaryForegroundColor)
                    .background(RoundedRectangle(cornerRadius: SwiftUIConstants.fieldsCornerRadius)
                        .strokeBorder(SwiftUIConstants.primaryAccentColor, style: StrokeStyle(lineWidth: 1.0))
                    )
                    .cornerRadius(SwiftUIConstants.fieldsCornerRadius)
                }
                .padding(.bottom, 10)
                
                Button(action: {
                    updateProfile()
                }) {
                    Text("Update")
                        .padding()
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .background(SwiftUIConstants.primaryAccentColor)
                        .foregroundColor(SwiftUIConstants.primaryBackgroundColor)
                        .cornerRadius(SwiftUIConstants.buttonCornerRadius)
                }
                .padding(.top, 20)
                
                Spacer()
            }
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("Okay")))
            }
            
            if showSpinner {
                ProgressView()
                    .frame(width: 170, height: 50)
                    .progressViewStyle(.circular)
                    .tint(SwiftUIConstants.primaryAccentColor)
                    .scaleEffect(x: 1.5, y: 1.5, anchor: .center)
                    .padding()
                    .cornerRadius(SwiftUIConstants.fieldsCornerRadius)
            }
        }
    }
    
    private func updateProfile() {
        showSpinner = true
        
        Task {
            if let errorMessage = await viewModel.updateProfile() {
                alertMessage = errorMessage
                showAlert = true
                return
            }
            showSpinner = false
            
            UserService.shared = nil
            navigationController?.popToRootViewController(animated: true)
        }
    }
}

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView()
    }
}
