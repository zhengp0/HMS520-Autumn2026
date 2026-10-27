# create a name card with a name, phone number, and email address
john <- list(
  name = "John",
  phone_number = "206-123-1234",
  email = "john@gmail.com"
)

# peek into the list
str(john)

# check the type of the list
typeof(john)

# access element(s) in the name card
john$email
john[["email"]]
# DON'T DO IT!
john[[3]]

# change John's email address
john$email <- "john@uw.edu"
john

# remove John's phone number
john$phone_number <- NULL

# list of lists
lucy <- list(
  name = "Lucy",
  email = "lucy@uw.edu"
)

contacts <- list(
  john = john,
  lucy = lucy
)

# length
length(contacts)

# lapply
lapply(contacts, function(x) x$email)

# unlist
unlist(contacts)

# names
names(john)
