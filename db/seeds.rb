# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.create!( first_name: "Lucho",
              last_name:  "Crisalle",
              username:   "lucho",
              password:   "lucho",
              license:    "owner"
            )
             
User.create!( first_name:     "Russ",
              last_name:      "Sherman",
              username:       "russ4fitness@gmail.com",
              password:       "password",
              license:        "CFNS",
              company:        "XtraFit Lifestyle",
              website1:       "http://utahfitnessacademy.com/",
              work_address_1:  "13319 S Mosely Way",
              work_city:      "Herriman",
              work_state:     "UT",
              work_zip:       "84096",
              work_country:   "USA",
              email:          "russ4fitness@gmail.com",
              mobile_phone:   "(208) 242-7047"
            )
            
User.create!( first_name:     "Rhonda",
              last_name:      "Taylor",
              username:       "Rhonda",
              password:       "password",
              license:        "client",
              expiration_date:"2015-12-31",
              work_address_1:  "10624 S Eastern Ave",
              work_address_2:  "Suite A-783",
              work_city:      "Henderson",
              work_state:     "NV",
              work_zip:       "89052",
              work_country:   "USA",
              email:          "ronda@heartworkpublishing.com ",
              mobile_phone:   "303-549-3497",
              work_phone:     "702-463-4122",
              other_phone:    "FAX 815-555-5555"
            )