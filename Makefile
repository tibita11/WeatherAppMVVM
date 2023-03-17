.PHONY: apikey

apikey:
	@echo "let openWeatherAPIKey = \"$(APIKEY)\"" > ./WeatherAppMVVM/Model/OpenWeatherAPIKey.swift

