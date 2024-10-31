#  myChatGPT
Kodeco AI Bootcamp, 5th homework, ChatGPT integration into your own applications.


# Video walkthrough:
Please note that video is quite big (580MB, ~20min). Sorry for that, but I couldn't explain all the fatures shorter.
https://drive.google.com/file/d/1ruyaXfz0XmcKky8Bl7iSFTlulv0BFTGy/view?usp=sharing


# WARNING:
To see this app working, you have to provide your OpenAI API Key in **GPTClient** class:
*private let apiKey = "...your API key here..."*


# NOTES:
1. Please note that this app DO NOT NEEDS to be run on real iPhone device. Therefore you can run it on the simulator as well. Just remember that min. iOS version is 18.0.
2. By default I used **gpt-3.5-turbo** which is the economical choice. This model is the cheapest. Giving a possibility to change the model during the conversation seems to be pointless due to losing context in such switching. However, if you want to use a newer, better and more expensive model like **gpt-4o** or **gpt-4-turbo**, you have to change it in **ContentView** class:
	
	...
	var client = GPTClient(
		model: .gpt35Turbo // <- change here
	...
2. Communication with ChatGPT is based on network communication, so a WIFI connection is necessary.
3. Although the app's goal was to prohibit conversations about topics unrelated to cars, which I did, I did allow my assistant to answer a few additional sub-topics, such as: name, change the conversation language, and question about whether he is a robot or a human. I did it on purpose to make the chat more human-friendly. From my experience, I know that such kind of questions are often asked in conjunction with the main topic, in systems like this one.

# Noteworthy features:
- automatic chat scroll, with new messages appearing from the bottom;
- automatic sending of messages after pressing [Return] - option only on the simulator;
- showing/hiding the keyboard to better see messages in the chat list;
- conversion of ChatGPT responses to AttributedString to mark url links and be able to click them to open the page in the web browser;
- error handling, especially handling of lost network connection;
- prompt for too long and proposal to start a new one (after 10 messages)
- ability to copy messages to clipboard
- (tech.) wrapped GPTMessage due to warning from ForEach regarding duplicated IDs (unique indexing for the same messages)
- extended scope of ChatGPT responses:
	* car problems or car improvements
	* talking about ChatGPT (name, is the assistant human or robot)
	* conversation language, and permission to change the language
	* if the question is out of topic, chat can propose external links or steps, but does not give the help directly
