#  myChatGPT
Kodeco AI Bootcamp, 5th homework, ChatGPT integration into your own applications.


# Video walkthrough:
https://drive.google.com/file/d/1_wwNp_kF5qfdBEVz9QWsbCfeWsnOiQVg/view?usp=sharing


# WARNING:
You have to provide your OpenAI API Key in **GPTClient** class:
*private let apiKey = "...your API key here..."*


# NOTE 1:
Please note that this app DO NOT NEEDS to be run on real iPhone device. Therefore you can run it on the simulator as well. Just remember that min. iOS version is 18.0.


# NOTE 2:
By default I used **gpt-3.5-turbo** which is the economical choice. This model is the cheapest. If you want to use a newer, better and more expensive model like **gpt-4o** or **gpt-4-turbo**, you have to change it in **ContentView** class:
	
	...
	var client = GPTClient(
		model: .gpt35Turbo // <- change here
	...
		
Making it an option in the application I found too excessive.


# NOTE 3:
The application assumes that you are connected to the Internet. Communication with ChatGPT is based on network communication, so a WIFI connection is necessary. I did not implement handling of the lack of a network connection, and showing errors to the user. Comprehensive error handling is not the goal of this exercise, but in a commercial application it should be implemented, at least a prompt for a network connection.

#NOTE 4:
Although the app's goal was to prohibit conversations about topics unrelated to cars, which I did, I did allow my assistant to answer a few additional sub-topics, such as: name, conversation language, and whether he or she is a robot. All to make the chat more human-friendly. From experience, I know that these questions are often asked in conjunction with the main topic.

#NOTE 5:
At the last minute, after filming the video, I decided to remove hiding the keyboard when chat is scrolled. Instead, I added an additional button below the text field [show/hide keyboard]. Autoscrolling to the last chat message and capturing user interaction on the scroll were conflicting with each other.
