# terraform-api-gateway-lambda

### Changing Cognito User Password

 - While we can do it, it is not recommended to create the cognito users with the password as they will be embedded 
 - When the stack is deployed, a temporary password will be send to the email assigned to each cognito user you created.
 - Use the temporary password to send to this `initiate-auth` command

```bash
aws cognito-idp initiate-auth \
 --client-id ${CLIENT_ID} \
 --auth-flow USER_PASSWORD_AUTH \
 --auth-parameters USERNAME="${USERNAME}",PASSWORD="${TEMP_PASSWORD}"
```
  
 - you should see that the command fail, asking you to create a new password

```bash
{
    "ChallengeName": "NEW_PASSWORD_REQUIRED",
    "Session": "AYABeNul3AaFMd-iZbkcCbfEwtwAHQABAAdTZXJ2aWNlABBDb2duaXRvVXNlclBvb2xzAAEAB2F3cy1rbXMAUGFybjphd3M6a21zOmFwLXNvdXRoZWFzdC0xOjAzMTU3NzI0MDA0ODprZXkvYmEwNzA1YzktMTI0Mi00ODg1LWJhMmYtNDhiMWNjYTNiNDNmALgBAgEAeMtRirmB1qptVeI5EWSyPpLL6RXz-VVK9JVsLMBfSNNmAX_uSIUlhBEH2fm0CQyawWkAAAB",
    "ChallengeParameters": {
        "USER_ID_FOR_SRP": "${USERNAME}",
        "requiredAttributes": "[]",
        "userAttributes": "{\"email_verified\":\"true\",\"email\":\"example@gmail.com\"}"
    }
}
```

 - grab the session value and respond to the challenge to change to your new permanent password

```bash
aws cognito-idp respond-to-auth-challenge \
  --client-id ${CLIENT_ID} \
  --challenge-name NEW_PASSWORD_REQUIRED \
  --challenge-responses NEW_PASSWORD="${NEW_PASSWORD}",USERNAME="${USERNAME}" \
  --session "${SESSION_ID}"
```

 - with that done, we can try the same `initiate-auth` command again, and just extract the token id.

```

aws cognito-idp initiate-auth \
 --client-id ${CLIENT_ID} \
 --auth-flow USER_PASSWORD_AUTH \
 --auth-parameters USERNAME="${USERNAME}",PASSWORD="${NEW_PASSWORD}"
 --query 'AuthenticationResult.IdToken' \
 --output text
```
