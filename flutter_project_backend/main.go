package main

import (
	"fmt"
	"net/http"
	"os"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/driver/mysql"
	"gorm.io/gorm"
)

var hmacSampleSecret []byte

// Binding from JSON
type Register struct {
	Username string `json:"username" binding:"required"`
	Password string `json:"password" binding:"required"`
	Avatar   string `json:"avatar"`
	Fullname string `json:"fullname" binding:"required"`
}

// Binding from JSON
type LoginBody struct {
	Username string `json:"username" binding:"required"`
	Password string `json:"password" binding:"required"`
}

// model Tbl_user
type Tbl_user struct {
	gorm.Model
	Username string
	Password string
	Avatar   string
	Fullname string
}

func main() {

	// connect mysql

	// ถ้าไม่มีรหัสให้ใช้อันนี้นะจ๊ะเเต่ถ้ามีก็เปลี่ยนไปใช้ข้างล่างเลยอย่าลืมเปลี่ยนรหัสผ่ารด้วย
	// dsn := "root@tcp(127.0.0.1:3306)/flutter_backend_go?charset=utf8mb4&parseTime=True&loc=Local"
	dsn := "root@tcp(127.0.0.1:3306)/flutter_backend_go?charset=utf8mb4&parseTime=True&loc=Local"
	db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{})
	if err != nil {
		panic("failed to connect database")
	}
	// migrate database
	db.AutoMigrate(&Tbl_user{})

	r := gin.Default()

	//Use Cors
	config := cors.DefaultConfig()
	config.AllowAllOrigins = true
	config.AllowCredentials = true
	config.AddAllowHeaders("authorization")
	r.Use(cors.New(config))

	// post
	r.POST("/register", func(c *gin.Context) {

		var json Register
		if err := c.ShouldBindJSON(&json); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}

		// if json.Username != "manu" || json.Password != "123" {
		//   c.JSON(http.StatusUnauthorized, gin.H{"status": "unauthorized"})
		//   return
		// }

		// c.JSON(http.StatusOK, gin.H{"status": "you are logged in"})
		encryptedPassword, _ := bcrypt.GenerateFromPassword([]byte(json.Password), 10)

		var userExist Tbl_user
		db.Where("username = ?", json.Username).First(&userExist)
		if userExist.ID > 0 {
			c.JSON(http.StatusOK, gin.H{"status": 400, "message": "User Exists"})
			return
		}

		// set str data
		user := Tbl_user{
			Username: json.Username,
			Password: string(encryptedPassword),
			Avatar:   json.Avatar,
			Fullname: json.Fullname,
		}

		// create data
		db.Create(&user)

		// check insert data to structure
		if user.ID > 0 {
			c.JSON(http.StatusOK, gin.H{
				"message":    "Finish insert data",
				"statuscode": 201,
			})
		} else {
			c.JSON(http.StatusOK, gin.H{
				"message":    "Server Error",
				"statuscode": 500,
			})
		}
	})

	r.POST("/login", func(c *gin.Context) {
		var json LoginBody
		if err := c.ShouldBindJSON(&json); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}
		// Check User Exists
		var userExist Tbl_user
		db.Where("username = ?", json.Username).First(&userExist)
		if userExist.ID == 0 {
			c.JSON(http.StatusOK, gin.H{"status": "error", "message": "User Does Not Exists"})
			return
		}

		err := bcrypt.CompareHashAndPassword([]byte(userExist.Password), []byte(json.Password))
		if err == nil {
			hmacSampleSecret = []byte(os.Getenv("JWT_SECRET_KEY"))
			token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
				"userId": userExist.ID,
				"exp":    time.Now().Add(time.Minute * 1).Unix(),
			})

			// Sign and get the complete encoded token as a string using the secret
			tokenString, err := token.SignedString(hmacSampleSecret)
			fmt.Println(tokenString, err)

			c.JSON(http.StatusOK, gin.H{"status": "ok", "message": "Login Success", "token": tokenString})
		} else {
			c.JSON(http.StatusOK, gin.H{"status": "error", "message": "Login Failed"})
		}
	})

	// get
	r.GET("/register", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"message": "register page",
		})
	})

	r.GET("/", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"message": "start migrate pages",
		})
	})

	r.Run() // listen and serve on 0.0.0.0:8080 (for windows "localhost:8080")
}
