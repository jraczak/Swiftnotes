package com.moonpi.swiftnotes;


import android.support.test.espresso.ViewInteraction;
import android.support.test.rule.ActivityTestRule;
import android.support.test.runner.AndroidJUnit4;
import android.test.suitebuilder.annotation.LargeTest;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;

import org.hamcrest.Description;
import org.hamcrest.Matcher;
import org.hamcrest.TypeSafeMatcher;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;

import static android.support.test.espresso.Espresso.onData;
import static android.support.test.espresso.Espresso.onView;
import static android.support.test.espresso.action.ViewActions.*;
import static android.support.test.espresso.assertion.ViewAssertions.*;
import static android.support.test.espresso.matcher.ViewMatchers.*;
import static org.hamcrest.CoreMatchers.allOf;
import static org.hamcrest.CoreMatchers.anyOf;

import android.support.test.runner.AndroidJUnit4;
import android.widget.TextView;

import android.support.test.runner.AndroidJUnit4;
import com.xamarin.testcloud.espresso.Factory;
import com.xamarin.testcloud.espresso.ReportHelper;




@LargeTest
@RunWith(AndroidJUnit4.class)
public class testCreateNote {

    @Rule
    public ActivityTestRule<MainActivity> mActivityTestRule = new ActivityTestRule<>(MainActivity.class);

    @Rule
    public ReportHelper reportHelper = Factory.getReportHelper();


    @Test
    public void testCreateFirstNote() {

        reportHelper.label("Given I click new note");
        onView(withId(R.id.newNote)).perform(click());

        reportHelper.label("Then I give the note a title");
        onView(withId(R.id.titleEdit)).perform(typeText("My first note"));

        reportHelper.label("Then I give the note content");
        onView(withId(R.id.bodyEdit)).perform(typeText("Today I created my first note."));

        reportHelper.label("Then I press the back button");
        onView(withContentDescription("Navigate up")).perform(click());

        reportHelper.label("And I confirm the save dialog");
        onView(withText("Yes")).perform(click());

        reportHelper.label("Then I should see the title of my note");
        onView(allOf(withText("My first note"))).check(matches(isDisplayed()));
    }

    @Test
    public void testCreateSecondNote() {

        reportHelper.label("Given I click new note");
        onView(withId(R.id.newNote)).perform(click());

        reportHelper.label("Then I give the note a title");
        onView(withId(R.id.titleEdit)).perform(typeText("Apples"));

        reportHelper.label("Then I give the note content");
        onView(withId(R.id.bodyEdit)).perform(typeText("Oranges"));

        reportHelper.label("When I navigate back");
        onView(withContentDescription("Navigate up")).perform(click());

        reportHelper.label("And I confirm the save dialog");
        onView(withText("Yes")).perform(click());

        reportHelper.label("Then I should see the title of my note");
        // Note that we expect this test to fail since "Bananas" was not part of the note content
        onView(allOf(withText("Bananas"))).check(matches(isDisplayed()));
    }


    private static Matcher<View> childAtPosition(
            final Matcher<View> parentMatcher, final int position) {

        return new TypeSafeMatcher<View>() {
            @Override
            public void describeTo(Description description) {
                description.appendText("Child at position " + position + " in parent ");
                parentMatcher.describeTo(description);
            }

            @Override
            public boolean matchesSafely(View view) {
                ViewParent parent = view.getParent();
                return parent instanceof ViewGroup && parentMatcher.matches(parent)
                        && view.equals(((ViewGroup) parent).getChildAt(position));
            }
        };
    }
}
