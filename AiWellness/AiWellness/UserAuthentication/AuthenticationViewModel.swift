//
//  AuthenticationViewModel.swift
//  AiWellness
//
//  Created by Lucija Iglič on 3. 1. 25.
//

import Foundation

class AuthenticationViewModel {
    var autheticationService: AuthenticationService

    init(autheticationService: AuthenticationService) {
        self.autheticationService = autheticationService
    }

    func googleSignIn() {
        autheticationService.googleSignIn()
    }

    func googleSignOut() {
        autheticationService.googleSignOut()
    }
}
