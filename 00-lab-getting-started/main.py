import os
from openai import AzureOpenAI
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Make sure these environment variables are set
if not os.getenv("AZURE_OPENAI_ENDPOINT") or not os.getenv("CHAT_COMPLETIONS_DEPLOYMENT_NAME") or not os.getenv("AZURE_OPENAI_API_KEY"):
    print("Error: Required environment variables are not set.")
    print("Please set AZURE_OPENAI_ENDPOINT, CHAT_COMPLETIONS_DEPLOYMENT_NAME, and AZURE_OPENAI_API_KEY")
    exit(1)

# Get environment variables
endpoint = os.environ["AZURE_OPENAI_ENDPOINT"]
deployment = os.environ["CHAT_COMPLETIONS_DEPLOYMENT_NAME"]
api_key = os.environ["AZURE_OPENAI_API_KEY"]

# Create a client with only the required parameters
client = AzureOpenAI(
    azure_endpoint=endpoint,
    api_key=api_key,
    api_version="2024-02-01"
)

# Enter a query is added to the messages list
user_query = input("Enter your query: ")

try:
    completion = client.chat.completions.create(
        model=deployment,
        messages=[
            {
                "role": "user",
                "content": user_query,
            },
        ]
    )

    # Extract response content
    response_content = completion.choices[0].message.content
    print("\nResponse:")
    print(response_content)

    # Optional: Print raw response
    print("\nRaw Response:")
    print(completion.model_dump_json(indent=2))

except Exception as e:
    print(f"Error: {e}")
