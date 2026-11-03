import Foundation

extension User {
    init(dto: UserDTO) {
        self.init(id: dto.id, username: dto.username, displayName: dto.displayName, phone: dto.phone)
    }
}
