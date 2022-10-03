developer = User.create(name: "Developer", user_name: "developer", email: "developer@gmail.com", password: "devbox@123", roles_mask: 1)
super_admin = User.create(name: "F99Admin", user_name: "f_99_super_admin", email: "f_99_super_admin@gmail.com", password: "devbox@123", roles_mask: 2, created_by_id: developer.id, company_type: "f99")
User.create(name: "F99Admin", user_name: "f_99_admin", email: "f_99_admin@gmail.com", password: "devbox@123", roles_mask: 4, created_by_id: super_admin.id)


Country.create(title: "Pakistan")
City.create(title: "Lahore")
ItemType.create(title: "default",code: "default")
ProductCategory.create(code: "default Category", title: "default Category")
ExpenseType.create(title: "Expense")
