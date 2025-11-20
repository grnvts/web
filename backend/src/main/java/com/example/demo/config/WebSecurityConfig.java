package com.example.demo.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.method.configuration.EnableGlobalMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.servlet.config.annotation.CorsRegistry;

import com.example.demo.jwt.config.JwtAuthenticationEntryPoint;
import com.example.demo.jwt.config.JwtRequestFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

@Configuration
@EnableWebSecurity
@EnableGlobalMethodSecurity(prePostEnabled = true)
public class WebSecurityConfig extends WebSecurityConfigurerAdapter 
{
	@Autowired
	private JwtAuthenticationEntryPoint jwtAuthenticationEntryPoint;

	@Autowired
	private UserDetailsService jwtUserDetailsService;

	@Autowired
	private JwtRequestFilter jwtRequestFilter;

	@Autowired
	public void configureGlobal(AuthenticationManagerBuilder auth) throws Exception {
		auth.userDetailsService(jwtUserDetailsService).passwordEncoder(passwordEncoder());
	}


	@Bean
	public CorsConfigurationSource corsConfigurationSource() {
		CorsConfiguration configuration = new CorsConfiguration();
		configuration.addAllowedOrigin("http://localhost:3000"); // Или "*", но лучше конкретно
		configuration.addAllowedMethod("*");
		configuration.addAllowedHeader("*");
		configuration.setAllowCredentials(true); // если нужен jwt-cookie
		UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
		source.registerCorsConfiguration("/**", configuration);
		return source;
	}

	@Bean
	public PasswordEncoder passwordEncoder() {
		return new BCryptPasswordEncoder();
	}

	@Bean
	@Override
	public AuthenticationManager authenticationManagerBean() throws Exception {
		return super.authenticationManagerBean();
	}

	@Override
	protected void configure(HttpSecurity http) throws Exception {
		
        http
        .cors()
        .and()
        .csrf().disable()

        .authorizeRequests()
				.antMatchers("/swagger-ui/**", "/v3/api-docs/**").permitAll()
        .antMatchers(HttpMethod.GET,"/images/**").permitAll()
        .antMatchers(HttpMethod.POST,"/api/login").permitAll()
        .antMatchers(HttpMethod.POST,"/api/user").permitAll()
		.antMatchers(HttpMethod.GET, "/api/user/users").hasRole("ADMIN") //ROLE_ из названия роли надо опустить тк автоматически убирается
				.antMatchers("/api/orders/brigadier/active").hasRole("BRIGADIER")
				.antMatchers(HttpMethod.GET, "/api/orders/my").authenticated()
				.antMatchers(HttpMethod.GET, "/api/orders/**").authenticated()
				.antMatchers(HttpMethod.POST, "/api/orders").authenticated()
				.antMatchers(HttpMethod.POST, "/api/orders/brigadier/my").authenticated()
				.antMatchers(HttpMethod.POST, "/api/orders/brigadier").authenticated()
				.antMatchers(HttpMethod.GET, "/api/brigade/all").hasRole("ADMIN")
				.antMatchers(HttpMethod.GET, "/api/user/masters").hasAnyRole("ADMIN", "BRIGADIER")
				.antMatchers("/api/user/**").authenticated()
				.antMatchers("/swagger-ui/**", "/v3/api-docs/**").permitAll()
        .and()
        .authorizeRequests().anyRequest().authenticated()
        .and()
        .exceptionHandling().authenticationEntryPoint(jwtAuthenticationEntryPoint)
        .and()
        .sessionManagement().sessionCreationPolicy(SessionCreationPolicy.STATELESS);
		http.addFilterBefore(jwtRequestFilter, UsernamePasswordAuthenticationFilter.class); // Add our custom JWT security filter
		
		

	}
}
