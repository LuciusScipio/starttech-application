package config

import (
	"strings"

	"github.com/spf13/viper"
)

type Config struct {
	ServerPort         string   `mapstructure:"PORT"`
	MongoURI           string   `mapstructure:"MONGO_URI"`
	DBName             string   `mapstructure:"DB_NAME"`
	JWTSecretKey       string   `mapstructure:"JWT_SECRET_KEY"`
	JWTExpirationHours int      `mapstructure:"JWT_EXPIRATION_HOURS"`
	EnableCache        bool     `mapstructure:"ENABLE_CACHE"`
	RedisAddr          string   `mapstructure:"REDIS_ADDR"`
	RedisPassword      string   `mapstructure:"REDIS_PASSWORD"`
	LogLevel           string   `mapstructure:"LOG_LEVEL"`
	LogFormat          string   `mapstructure:"LOG_FORMAT"`
	CookieDomains      []string `mapstructure:"COOKIE_DOMAINS"`
	SecureCookie       bool     `mapstructure:"SECURE_COOKIE"`
	AllowedOrigins     []string `mapstructure:"ALLOWED_ORIGINS"`
}

func LoadConfig(path string) (config Config, err error) {
	// 1. Tell Viper where to find the config file
	viper.AddConfigPath(path)
	viper.SetConfigName("app") // Change this to 'app' or 'config'
	viper.SetConfigType("env") // This tells it the FORMAT is env (like a .env file)

	// 2. This is the secret sauce for AWS/Docker
	// It tells Viper to look for a file named exactly ".env"
	viper.SetConfigFile(".env") 

	// 3. Enable reading from System Environment Variables (CRITICAL for AWS)
	viper.AutomaticEnv()

	// Default values
	viper.SetDefault("PORT", "8080")
	viper.SetDefault("ENABLE_CACHE", false)
	viper.SetDefault("JWT_EXPIRATION_HOURS", 72)

	// 4. Attempt to read the file, but don't panic if it's missing (Env vars will be used instead)
	if err := viper.ReadInConfig(); err != nil {
		if _, ok := err.(viper.ConfigFileNotFoundError); !ok {
			// If it's a real error (like a syntax error in the file), return it
			return config, err 
		}
	}

	err = viper.Unmarshal(&config)
	if err != nil {
		return
	}

	// 5. Clean up Slices (Viper sometimes struggles with comma-separated strings in .env files)
	config.AllowedOrigins = parseSlice(viper.GetString("ALLOWED_ORIGINS"), []string{"http://localhost:5173"})
	config.CookieDomains = parseSlice(viper.GetString("COOKIE_DOMAINS"), []string{"localhost"})

	return
}

// Helper function to clean up comma-separated strings from your .env
func parseSlice(input string, defaultVal []string) []string {
	if input == "" {
		return defaultVal
	}
	parts := strings.Split(input, ",")
	var cleaned []string
	for _, p := range parts {
		trimmed := strings.Trim(strings.TrimSpace(p), "\"'")
		if trimmed != "" {
			cleaned = append(cleaned, trimmed)
		}
	}
	return cleaned
}