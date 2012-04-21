class TrustResponderMailSeries < ActiveRecord::Base
  belongs_to :buyer_notification

  TRUST_EMAIL_SUBJECT = { "trust_responder_email1" => "The Most Common Questions About Owner Finance",
                          "trust_responder_email2" => "Is Owner Financing Right For You?",
                          "trust_responder_email3" => "Avoiding Owner Finance Scams",
                          "trust_responder_email4" => "3 Fatal Home Buyer Mistakes To Avoid",
                          "trust_responder_email5" => "7 Keys to Success When Buying A Home WIth Owner Financing",
                          "trust_responder_email6" => "Top Tips To Avoid Getting Ripped Off in Home Buying",
                          "trust_responder_email7" => "3 Tips To Leveraging Your Offer For A Quick Approval"}

  TRUST_EMAIL_BODY = { "trust_responder_email1" => "Hi {Buyer first name},
                              <br/><br/>
                              I saw that you set up your profile on my website and I look forward
                              to helping you find an owner-financed home.<br/><br/>

                              I wanted to send you a quick email since so many buyers I work with
                              aren't exactly sure how owner financing works.  I've found it
                              usually helps if I can help by answering some of the most common
                              questions up front.<br/><br/>

                              I'm sure you'll have questions beyond these here and I'm always
                              available if you want to email or call me so that I can help explain
                              the options you have available.<br/><br/>

                              In the meantime, here is some of the most common questions and
                              answers about buying a home with owner financing.<br/><br/>

                              How does owner financing work?  Owner financing is when the owner
                              of a home is acting as a bank and finances the home to you,
                              typically for 2-5 years which is usually enough time to work on your
                              credit and other issues so that you can obtain traditional financing
                              in order to refinance the loan.<br/><br/>

                              It's important to understand that with owner financing, you will get
                              the deed  to the home and after the warranty deed has been filed,
                              you will be listed in public records as the legal owner.  This also
                              means that you get all of the tax advantages and you have equitable
                              rights to the home, just like you would if you were getting a                            traditional mortgage from a bank.<br/><br/>

                              Owner finance homes sell fairly quickly since there are more buyers
                              looking than there are homes available.   Additionally, most sellers
                              offering owner financing are well versed in the process which means
                              owner financing can be very tricky and risky for a buyer if they are
                              not familiar with all the inner workings of this type of
                              transaction.  As a result, it's vitally important to do your
                              research and work with someone who specializes in this process so
                              that you have reliable guidance and expertise to ensure your
                              interests are protected. <br/><br/>

                              How much down payment do I need?  Down payments will vary.
                              Typically they can start as low as 5% and go as high as 20%, it all
                              depends on the seller.<br/><br/>

                              Are there any specific requirements to qualify to buy an
                              owner finance home?  Owner financing is typically NOT based on
                              credit score or credit history. This allows anyone with a will to
                              own a home, an opportunity for home ownership. Every seller
                              offering owner financing is different, for the most part they are
                              offering financing for those that cannot obtain a mortgage today.                            The single most important requirement to buy an owner finance home
                              is to have a minimum down payment of 5%.  <br/><br/>

                              How quick can we close?  Unlike using conventional lending to buy a
                              home which can take upwards of 45 days just to get through
                              underwriting and to the closing table, owner finance transactions
                              can close in a matter of days.   If the seller is flexible and you
                              are prepared as the buyer, it is possible to start your home search
                              on Monday and be closing and moving in by Friday.<br/><br/>

                              Like I said before, feel free to send me a quick email or give me
                              a call if you have any further questions that I didn't address in
                              this email and I'd be happy to discuss your options with you
                              further.<br/><br/>

                              Warm Regards,<br/><br/>

                              {Investor full name}<br/>
                              {Company name}<br/>
                              {Company address}<br/>
                              {Company phone}",

                              # STATIC DATA FOR EMAIL2
                              "trust_responder_email2" => "Hi {Buyer first name},<br/><br/>
                                A lot of buyers I work with ask me the if I think owner financing
                                is the right way for them to go.  To be honest, it all depends on
                                your particular situation.<br/><br/>

                                I mean, we all know that a major part of the 'American Dream' is
                                home ownership. Yet, as lending guidelines have tightened, home
                                ownership has become increasingly difficult.<br/><br/>

                                For many buyers and possibly you too, this has left you with only
                                one option if you want to buy a home and that's some type of
                                owner financing strategy.<br/><br/>

                                Buyers that can benefit from owner financing are...<br/><br/>

                                - Credit Challenged buyers who may have experienced some late
                                payments, collections or possibly bankruptcy.<br/><br/>

                                - Self Employed Buyers who can't prove their income or have
                                changed jobs recently also have a problem adhering to the strict
                                lending guidelines.<br/><br/>

                                - Traditional Buyers who may have great credit, but they have
                                other issues,  like lack of a 2 year employment history, that
                                prevent them from obtaining a conventional bank loan.<br/><br/>

                                - Individual Tax Identification Number (ITIN) Buyers which are
                                foreign buyers with no social security number and have a hard time
                                obtaining conventional loans in any market.<br/><br/>

                                - Real Estate Investors who have reached the maximum limit of
                                loans that they can get approved for with a traditional lending
                                source.<br/><br/>

                                Additionally, owner financing is great if you can't afford the
                                high closing costs of a conventional loan because you can save
                                thousands of dollars in closing costs when you are using
                                owner financing.<br/><br/>

                                Plus, owner financing is also ideal if you need to move into a
                                home fast.  It can take 30 - 45 days to close using conventional
                                financing, but you can close on a owner finance home in less than
                                a week.<br/><br/>

                                I think that the more appropriate question to ask is, when is
                                owner financing NOT right for me? <br/><br/>

                                My answer to that is that if you are within 6 to 12 months of
                                being able to get a bank loan, and that is your goal, then you need
                                to crunch the numbers and evaluate the home purchase carefully to
                                determine whether this type of purchase strategy is going to
                                benefit you or not.<br/><br/>

                                The biggest factor you'll want to consider is the price and value
                                of the home.  Since you'll be refinancing so soon, you will want to
                                make sure the home is going to appraise or have a clause in the
                                owner finance contract to protect you if it doesn't.<br/><br/>

                                I hope all this info helps!!  I'll chat with you soon.<br/><br/>

                                Warm Regards,<br/><br/>

                                {Investor full name}<br/>
                                {Company name}<br/>
                                {Company address}<br/>
                                {Company phone}",

                            # STATIC DATA FOR EMAIL3

                            "trust_responder_email3" => "Hi {Buyer first name}, <br/><br/>

                            I just wanted to send another quick email to review some of the
                            things you SHOULD be asking when we are out looking at homes.<br/><br/>

                            We can discuss a lot of this in more detail if you have questions,
                            but I wanted to get a head start so that you can be thinking about
                            some of the things that we will want to watch out for.<br/><br/>

                            Question: Do I get the deed?<br/><br/>

                            As I mentioned earlier, owner financing transactions do give you
                            the deed to the home and that is critical for your protection as
                            the buyer.  Homes that are advertising rent to own, lease option,
                            land contract etc do not give you the deed.  This is critical for
                            you to understand to avoid owner finance scams that say you're
                            getting full ownership rights when in fact, legal title is not
                            being transferred to you at closing.<br/><br/> 
                            Question: What liens are on the property?<br/><br/>

                            This is an important question because you will want to make sure
                            all liens that are attached to the property have been fully
                            disclosed before closing.  there are no other liens attached to
                            the home except the mortgage.  Some examples of liens that may be
                            attached to the home other than a mortgage might be judgements,
                            IRS liens, vendors liens, etc.<br/><br/>

                            The reason this is so important is because when we close on the
                            house and title transfers to you, any liens on the property will
                            transfer with the title which means you are stuck with them.<br/><br/>

                            Of course, we will get a title search done before we close but this
                            will save us time if we get all of this information up front.<br/><br/>

                            Question: What are the terms of the balloon payment?<br/><br/>

                            If you already read my free report, you'll remember that I
                            discussed making sure you have a loan extension clause and an
                            appraisal clause in the contract.  These are all terms that are
                            tied with the balloon payment.<br/><br/>

                            It's important that we make sure that your balloon is long enough
                            to get the home refinanced and has the necessary clauses to protect
                            you from unforeseen issues.<br/><br/>

                            Question: Will I have the right and the time to get a home
                            inspection?<br/><br/>

                            Inspections are really important to make sure there isn't anything
                            seriously wrong with the property that isn't obvious when we go see
                            the home.<br/><br/>

                            Whenever we write up an offer, we will want to make sure you have
                            the opportunity to get an inspection done before you commit any
                            serious money in a contract.<br/><br/>

                            I hope all this information is useful to you.  I am looking forward
                            to getting you into a home you love!<br/><br/>

                            Warm Regards,<br/><br/>
                            {Investor full name}<br/>

                            P.S.  I forgot to mention this to you earlier but if you really want
                            to dig in and learn everything you can about buying a home with
                            owner financing, here is a link to the Home Buying Success Formula,<br/>
                            http://budurl.com/homebuyingsuccess<br/>
                            written specifically for buyers who are looking for creative
                            financing strategies to buy their next home.<br/><br/>

                            {Company name}<br/>
                            {Company address}<br/>
                            {Company phone}",

                        # STATIC DATA FOR EMAIL4

                          "trust_responder_email4" => "Hi {Buyer first name}, <br/><br/>

                          I hope these quick daily emails are helping answer all of your
                          questions about owner financing.  I try to keep them short because
                          I know how valuable all of our time is, so if I haven't addressed
                          anything that you are still wondering about, you can call me
                          anytime or just drop me an email and I'll get back to you as soon
                          as I can.<br/><br/>

                          I think yesterday I emailed you about my list of questions I tell
                          all my buyers that you need to remember to ask.<br/><br/>

                          There are so many variables in owner finance transactions and it's
                          all too easy to make extremely fatal mistakes if you don't know what
                          you're doing.<br/><br/>

                          Here are 4 of them, off the top of my head...<br/><br/>

                          Mistake #1:  Paying your monthly mortgage payment in cash.<br/><br/>

                          There are a couple reasons making your mortgage payment in cash
                          is a fatal mistake.<br/><br/>

                          First, there is no real method of tracking the payment and if you
                          can't track the payment, then you also can't prove you made it.
                          No proof means you also have no legal recourse in case anything
                          gets fishy.<br/><br/>

                          Plus, being able to show and prove your monthly payments is
                          absolutely essential if you want to ever refinance the home.
                          If you can't show that you made consistent on-time payments for
                          a period of 12 months or more, no lender is going to be willing
                          to consider any type of refinance scenario which could leave you
                          in default of your original contract if there is any kind of
                          balloon on your note (which usually there is).<br/><br/>

                          Mistake #2:  Failing to be diligent about getting ready to
                          successfully refinance the home before the balloon expires.<br/><br/>

                          Depending on the contract, not paying attention or more commonly,
                          forgetting about the balloon date could mean you don't get your
                          affairs in order so that you can refinance and if you can't
                          refinance then you'll likely be facing an upcoming foreclosure.<br/><br/>

                          In fact, some sellers may even be hoping to foreclose. There are
                          a couple reasons why foreclosing is sometimes appealing to a seller:<br/><br/>

                          1. Depending on how long you have lived there, the home has likely
                          appreciated in value.<br/><br/>

                          What that means is that the seller can foreclose, keep the equity
                          that accrued since you've been there, they already have your
                          down payment and now they can find a new buyer with another down
                          payment and start the process all over.<br/>

                          2. Credit repair is a pretty lengthy process and it's not an exact
                          science so for the above reasons, it's even more important to plan
                          ahead and ensure you are not exposing yourself to a potential
                          foreclosure down the road.<br/><br/>

                          Mistake #3:  Not hiring a third party servicing company or
                          maintaining communication with the seller to verify that all
                          payments are being made.<br/><br/>

                          Using third party servicing companies is the #1 solution for this
                          one.  These companies not only ensure all payments are made but
                          they will also keep in contact with both parties to update them
                          on a monthly basis.<br/><br/>

                          This helps remove fears on both the buyer and seller side of the
                          transaction and helps ensure that all money is handled and directed
                          to the appropriate parties each month.<br/><br/>

                          Ultimately it's going to be your decision if you use a third party
                          servicing company or not but if you don't, it's imperative that you
                          maintain communication with the seller to verify all monthly
                          payments.<br/><br/>

                          Warm Regards,<br/><br/>

                          {Investor full name}<br/>

                          P.S.  I don't know if you checked out the
                          Home Buying Success Formula yet, but it's another
                          helpful tool with loads of great info.   You can check it out
                          here: http://budurl.com/homebuyingsuccess<br/><br/>

                          {Company name}<br/>
                          {Company address}<br/>
                          {Company phone}",

                          # STATIC DATA FOR EMAIL5

                          "trust_responder_email5" => "Hi {Buyer first name}, <br/><br/>

                          I hope you're having a great day, I wanted to send a quick email
                          about some important keys to a smooth owner finance transaction.<br/><br/>

                          As with anything in life, having a team of experts in your corner
                          will ensure you don't fall through too many traps and make
                          unnecessary mistakes that could have been prevented.<br/><br/>

                          Owner finance transactions are no exception.  I have created a team
                          of people I work with to get experts in ever field on our side
                          once we find a a home and write up an offer contract.<br/><br/>

                          These people are incredibly important to have in our corner to
                          give you the most leverage and the most protection.<br/><br/>

                          1.  An owner finance specialist.<br/><br/>

                          This one is easy, cause that's me...  :-)<br/><br/>

                          There are many different variations of owner finance transactions
                          and many sellers will SAY they are offering owner financing but in
                          reality, you aren't getting legal title.<br/><br/>

                          Examples of these transactions are things like Land Contracts,
                          Contract For Deed, Installment Contract, Equity Holding Trusts,
                          Rent To Own, Lease Options or Lease Purchase, among others.<br/><br/>

                          By working with someone like me, who specializes in owner financing,
                          I can explain the differences in each of these transactions and
                          offer recommendations to help you make educated decisions on which
                          one might be best for you.<br/><br/>

                          2.  A Lender or mortgage broker.<br/><br/>

                          Having a lender on your team will not only help you win
                          favor with the seller, but it will ensure a higher rate of success in your mission to get refinanced within the terms you agree to in your contract.<br/><br/>

                          This will be especially important when you want to make an offer
                          on a home for the following reason:  If you are competing against
                          any other buyers for the same property, this one thing alone can
                          give you the upper hand.<br/><br/>

                          3.  A Credit repair company.<br/><br/>

                          For anyone who needs help improving their credit, hiring a credit
                          repair company is going to give you more leverage when making an
                          offer on a home.  Plus, it will give you peace of mind.<br/><br/>

                          Many buyers get incredibly overwhelmed with the process of
                          repairing their credit.  They think they can do it on their own but
                          suddenly 2 years have past and they never found the time to sit
                          down, write all the letters and keep up with the timelines of each
                          credit bureau.<br/><br/>

                          On the other hand, buyers who hired credit repair companies to
                          help them were many times in a position to be able to refinance
                          within 12 short months.<br/><br/>

                          4. A Real Estate Attorney.<br/><br/>

                          This is the most important one of all, and rest assured, I have a
                          real estate attorney on my team!  This is absolutely imperative that
                          we are working with an attorney who specializes in these
                          transactions because attorney's who specialize in owner financing
                          will keep up to date on all the state laws and ensure we are all
                          protected.<br/><br/>

                          5.  Title companies.<br/><br/>

                          Most of the time, I do my closings in an attorney's office but it
                          is very important that if we aren't closing at an real estate
                          attorney's office, then we need to close at a title company.
                          Again, this is just another layer of protection for you.<br/><br/>

                          Title companies are required to have licensed closing agents and
                          attorneys on staff and they will act as a neutral third party
                          witness to the contract in case there are any future disputes.<br/><br/>

                          6.	Third-Party Servicing Companies.<br/><br/>

                          I think I mentioned this to you the other day in one of my emails.
                          A  third-party servicing company is responsible for all incoming
                          payments pertaining to the property and they distribute the money
                          to the appropriate parties.  This is the most reliable way to go in
                          any owner finance transaction to protect yourself and be able to
                          track and prove all the payments you have made.<br/><br/>

                          Many companies also maintain escrow accounts and make the annual
                          payments as needed.<br/><br/>

                          What I love most about this is that it takes a ton of
                          responsibility off both the buyer and seller to ensure all parties
                          are abiding by the contract terms.   It also makes it easy for
                          buyers and sellers to follow up on any questions they have to make
                          sure everything is being handled as it should.<br/><br/>

                          7.  Insurance agent.<br/><br/>

                          Working with an insurance agent who knows how to prepare a
                          homeowners insurance binder in an owner finance transactions is
                          absolutely critical.<br/><br/>

                          When you find a property, we are going to discuss the two options
                          you have with homeowner's insurance.  The first will be to add
                          yourself to the existing homeowners insurance policy as an
                          additional insured.<br/><br/>

                          The second option is to acquire your own homeowners insurance
                          policy and list the seller as either the primary loss payee or
                          secondary loss payee depending on if there is an underlying lien.<br/><br/>

                          I personally recommend option #1 for a couple reasons.  First, it's
                          simpler, second, it saves you money at closing and third, there is
                          no real danger of raising any flags with the bank when they see a
                          insurance policy change.<br/><br/>

                          Let me know if any of this raises any questions we haven't
                          discussed yet.<br/><br/>

                          Warm Regards,<br/><br/>

                          {Investor full name}<br/>

                          P.S.  Don't forget to check out the video about the
                          Home Buying Success Formula if you haven't already...it's
                          only 7 minutes and it may have more information that you're
                          looking for.  Here's the link again...<br/>
                          http://budurl.com/homebuyingsuccess<br/><br/>

                          {Company name}<br/>
                          {Company address}<br/>
                          {Company phone}",

                          # STATIC DATA FOR EMAIL6
                          "trust_responder_email6" => "Hi {Buyer first name}, <br/><br/>

                          How's things going?  We've been so busy, I wanted to hurry up
                          and get this email off to you.<br/><br/>

                          One of the things that has always astounded me was to learn that
                          the #1 fear of most buyers I work with is getting ripped off.<br/><br/>

                          In fact, it's been the buyers I've met before you who inspired
                          me to make sure I was providing valuable information to all my
                          new buyers because they had so many questions and fears of making
                          mistakes.<br/><br/>

                          So that's what I decided to email you about today, but I gotta be
                          quick so here we go...<br/><br/>

                          Tip #1:  We need to make sure a title search is done prior to
                          the purchase.<br/><br/>

                          There are a few reasons this mistake could cost you thousands.
                          First, if the seller doesn't hold legal title and you don't know
                          it, they will take your down payment and later you'll eventually
                          realize you never really were transferred legal title.<br/><br/>

                          Next, the title search will help you discover all the current liens
                          on the home which is something I mentioned to you previously but
                          there's another reason why this is important that we didn't discuss
                          and that is  that we want to make sure that the underlying is not
                          more than the agreed upon purchase terms.<br/><br/>

                          Tip #2:  You don't want to be using the county tax assessment as
                          your benchmark for the homes value.<br/><br/>

                          Even in a good market, this is true.  Home sellers may have fought
                          their taxes in a bad market or in a down market, they may not have
                          protested their taxes.<br/><br/>

                          The best way to determine value on a property is to do a
                          Comparative Market Analysis.  This will take any current actives
                          and recent sold homes into consideration in order to determine
                          today's current market value and this is something I can do for
                          you when we find you a home.<br/><br/>

                          Tip #3:  If you can help it, you really don't want to be making
                          your monthly mortgage payments directly to the seller if there is
                          an underlying lien holder.<br/><br/>

                          I know we have discussed this briefly before but what I didn't
                          tell you is that this used to be a fairly common con for sellers
                          who would sell their home with an underlying lien and use
                          owner financing.<br/><br/>

                          The sellers would not only pocket the buyers down payment, but they
                          would also pocket the monthly mortgage payment and never pay the
                          bank.  This left both parties in a position where they were facing
                          foreclosure, but the seller was leaving with a good amount of the
                          buyer's cash in hand.<br/><br/>

                          Ok, i gotta run but hopefully all this information is really
                          helping you.  Feel free to give me a ring or send me an email
                          if you have any other questions.<br/><br/>

                          Warm Regards,<br/><br/>

                          {Investor full name}<br/>

                          P.S.  I just wanted to include this video link again in case
                          you haven't checked it out.  The couple who wrote this book took
                          all their experiences and owner finance case studies and used
                          those to fill up this book with valuable information about
                          owner finance transactions to help other buyers.<br/><br/>

                          You can watch the video here: http://budurl.com/homebuyingsuccess<br/><br/>

                          {Company name}<br/>
                          {Company address}<br/>
                          {Company phone}",

                          # STATIC DATA FOR EMAIL7
                          "trust_responder_email7" => "Hi {Buyer first name},<br/><br/>

                          As we get prepared to make an offer on a house, I wanted to make
                          sure I told you 3 tips I've found that really  helps leverage
                          your offer for a quick approval.<br/><br/>

                          This is especially helpful if we are in a situation where we are
                          competing with other buyers who are also making offers.  These
                          tips will help us whiz through the entire process with ease:<br/><br/>

                          1.  We need to make sure we've already hooked you with a lender
                          who specializes in owner finance transactions.<br/><br/>

                          They are going to be able to tell you how much home you can afford
                          and how long you need before you are in a position to be able to
                          refinance.<br/><br/>

                          Then we will have them write a letter stating all the above
                          information, just like they would do when they provide a
                          pre-qualification letter to a traditional buyer.  Then we will
                          submit this letter with your offer.<br/><br/>

                          What this will do is it will show the seller how serious you are
                          about getting a home and refinancing it at some point in the
                          future.  It will also help us ensure that in negotiations you don't
                          agree to a contract with a shorter balloon than what you need.<br/><br/>

                          Most buyers don't take this step and if we are in a multi-offer
                          situation (which is common with owner finance homes because homes
                          are scarce), this extra step will give you the upper hand.<br/><br/>

                          2.  We will want to do this same thing with a credit repair company.<br/><br/>

                          We will put the credit repair company info on the buyers
                          application or I can just mention it to the seller.  This extra
                          step will not only set you up to succeed but it will prove your
                          intent on getting your credit back in shape so you can refinance
                          which is something the seller will like to see.<br/><br/>

                          3.  Start gathering documentation that will help support your
                          offer and show your ability to pay.  Here are some examples of
                          what we may need:<br/><br/>

                          -----> Proof of income and employment: Recent pay stubs or tax
                          returns if you are self employed or Bank deposit statements if
                          you get paid in 'creative' ways.<br/><br/>

                          -----> Proof of Funds for Down Payment:  Bank statement or a
                          letter from your bank stating you have enough funds on deposit to
                          cover the down payment.  (Black out your account numbers.)<br/><br/>

                          Owner finance homes are scarce, so if you take the initiative to
                          gather these few things up front, this will get you off on the
                          right foot with the seller, help your approval and negotiations
                          go quickly and possibly even give you the upper hand if you are
                          competing against another buyer's offer.<br/><br/>

                          I'm excited for you and I'm looking forward to getting you into
                          a home! Let me know if I can help you put any of this stuff
                          together so that we are ready to go as soon as you find a home
                          you love.<br/><br/>

                          Warm Regards,<br/><br/>

                          {Investor full name}<br/>

                          P.S.  Here's the video link for the Home Buying Success Formula
                          again, if you missed it.<br/>
                          http://budurl.com/homebuyingsuccess<br/>
                          They are giving away a ton of cool stuff!<br/><br/>
                          {Company name}<br/>
                          {Company address}<br/>
                          {Company phone}" }
  
  def self.get_trust_responder_notification(buyer_notification, trust_responder_summary_type)
    trust_responder_notification = buyer_notification.trust_responder_mail_series.find(:first,:conditions => ["trust_responder_summary_type LIKE ?",trust_responder_summary_type])
    return trust_responder_notification unless trust_responder_notification.blank?
    email_subject, email_body = TRUST_EMAIL_SUBJECT[trust_responder_summary_type], TRUST_EMAIL_BODY[trust_responder_summary_type]
    return TrustResponderMailSeries.new(:email_subject => email_subject, :email_body => email_body)
  end

  def self.get_example_for_trust_responder(trust_responder_summary_type)
    return TRUST_EMAIL_BODY[trust_responder_summary_type]
  end
end
